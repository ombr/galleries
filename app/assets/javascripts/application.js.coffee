#= require jquery
#= require angular/angular
#= require ngstorage/ngStorage
#= require node-uuid/uuid
#= require angular-ui-router/release/angular-ui-router
#= require angular-rails-templates
#= require async/lib/async
#= require lodash/dist/lodash
#= require blueimp-load-image/js/load-image.all.min
#= require blueimp-canvas-to-blob/js/canvas-to-blob
#= require angular-bootstrap/ui-bootstrap
#= require angular-utils-pagination/dirPagination
#= require angular-virtual-scroll/angular-virtual-scroll
#= require angular-vs-repeat/src/angular-vs-repeat
#= require_tree ./templates

angular.module('galleries.home', ['ngStorage', 'angularUtils.directives.dirPagination'])
  .directive 'fileDrop', ($window)->
    restrict: 'A'
    link: (scope, elem, attrs)->
      console.log 'fileDrop init'
      doNothing=(e)->
        e.preventDefault()
        e.stopPropagation()
      process = (files)->
        for file in files
          scope[attrs['fileDrop']](file)
        scope.$evalAsync()
      listener = ->
        process this.files
      drop_listener = (e)->
        doNothing(e)
        if e.originalEvent.dataTransfer
          process e.originalEvent.dataTransfer.files
      jwindow = $($window)
      jwindow.on 'dragover', doNothing
      jwindow.on 'dragenter', doNothing
      jwindow.on 'drop', drop_listener
      elem.on 'change', listener
      elem.on '$destroy', ->
        console.log 'Clean up drag and drop'
        elem.off 'change', listener
        jwindow.off 'drop', listener
        jwindow.off 'dragover', doNothing
        jwindow.off 'dragenter', doNothing
  .service 'Image', ($localStorage, $timeout, $rootScope)->
    class Image
      constructor: (@uid, @file)->
        @status = 'waiting'
        @filename = @file.name
        # @save()
        process_queue.push(this)
      file: ->
        @file
      save: ->
        $localStorage[@uid] =
          uid: @uid,
          filename: @filename
          status: @status
          exifs: @exifs
          image_small: @image_small
          image_large: @image_large
        $rootScope.$evalAsync()
        files = $localStorage.files
        files.push(@uid)
        files = _.uniq(files)
        $localStorage.files = files
      process: (callback)->
        if !@file.type.match(/image.*/)
          callback()
          return
        @status = 'processing'
        # @save()
        this.extract_exifs =>
          async.map [['small', 200, 200], ['large', 1920, 1080]], (args, callback)=>
            [version, x, y] = args
            this.process_version(version, [x, y], callback)
          , (err, res)=>
            # this.upload(callback)
            @status = 'processed'
            callback()
            $rootScope.$evalAsync()
            # @save()
      process_version: (version, size, callback)->
          loadImage @file, (img)=>
            return callback('error', null) if img.type == 'error'
            return callback('error', null) unless img.toBlob
            this["image_#{version}"] = img.toDataURL()
            img.toBlob (blob)=>
              this[version] = blob
              callback()
            ,
              'image/jpeg'
          ,
            maxWidth: size[0],
            maxHeight: size[1],
            canvas: true,
            orientation: @orientation
      extract_exifs: (callback)->
        loadImage.parseMetaData(@file, (data)=>
          @orientation = 1
          if data.exif
            @exifs = data.exif.getAll()
            @orientation = data.exif[0x0112]
          callback()
        ,
          disableExifThumbnail: true,
          disableImageHead: true,
        )
    process_queue = async.queue((image, callback)->
      image.process(callback)
    ,1)
    Image.process_queue = process_queue
    Image
        # this.extract_exifs =>
        #   async.map [[200, 200, true], [1920, 1080]], (size, callback)=>
        #     this.process_version(size, callback)
        #   , (err, res)=>
        #     [@small, @large] = res
        #     this.upload(callback)
  .controller 'homeCtrl', ($scope, $interval, $localStorage, Image)->
    $scope.images = []
    $scope.columns = 3
    $scope.perpage = 75
    $scope.round = Math.round
    $scope.rows = []
    $interval(->
      $scope.queue = Image.process_queue.length()
    ,500)
    # reload_rows = ->
    #   $scope.rows = []
    #   tmp = []
    #   for image,k in images
    #     tmp.push(image)
    #     if (k+1)%$scope.columns == 0
    #       $scope.rows.push(tmp)
    #       tmp = []
    #   $scope.rows.push(tmp) if tmp.length != 0
      # $scope.$evalAsync()
    # lazy_reload_rows = _.debounce(reload_rows, 500, leading: true)
    $scope.zoom = (num)->
      $scope.columns = num
    add_queue = async.queue((file, callback)->
      $scope.images.push(new Image(uuid.v4(), file))
      $scope.$evalAsync()
      callback()
    ,1)
    $scope.onDrop = (file)->
      add_queue.push(file)
angular.module('galleries', ['ui.router', 'galleries.home', 'templates', 'ui.bootstrap'])
  .config ($stateProvider, $urlRouterProvider)->
    $stateProvider
      .state('index', {
        url: '/',
        templateUrl: 'home.html',
        controller: 'homeCtrl'
      })
    $urlRouterProvider.otherwise('/')
   # .config (RestangularProvider)->
   #   # RestangularProvider.setBaseUrl('http://127.0.0.1:5000')
   #   RestangularProvider.setBaseUrl('http://poc-backend.herokuapp.com')
   #   return RestangularProvider
