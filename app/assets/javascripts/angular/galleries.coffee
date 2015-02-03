angular.module('galleries.home', ['angularUtils.directives.dirPagination', 'fileDrop', 'galleries.image'])
  .controller 'homeCtrl', ($scope, $interval, Image)->
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
    $scope.show = (images, image)->
      return unless image.processed
      items = _.where(images, processed: true)
      options = {
        history: false
        index: _.findIndex(items, image)
        getThumbBoundsFn: (index)->
          $image = $('#image-'+images[index].uid)
          $img = $('img', $image)
          offset = $img.offset()
          return {x: offset.left, y: offset.top, w: $img.width()}
      }
      gallery = new PhotoSwipe(document.querySelectorAll('.pswp')[0], PhotoSwipeUI_Default, items, options)
      gallery.init()
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
  .config ($locationProvider)->
    $locationProvider.html5Mode(
      enabled: true,
      requireBase: false
    )
