angular.module('galleries.image', ['ngStorage', 'ui.bootstrap.tooltip'])
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
            @processed = true
            @status = 'processed'
            @w = @image_width_large
            @h = @image_height_large
            @src = @image_large
            @msrc = @image_small
            callback()
            $rootScope.$evalAsync()
            # @save()
      process_version: (version, size, callback)->
          loadImage @file, (img)=>
            return callback('error', null) if img.type == 'error'
            return callback('error', null) unless img.toBlob
            this["image_#{version}"] = img.toDataURL()
            this["image_width_#{version}"] = img.width
            this["image_height_#{version}"] = img.height
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
      setTimeout((->
        image.process(callback)
      ), 100)
    ,1)
    Image.process_queue = process_queue
    Image
        # this.extract_exifs =>
        #   async.map [[200, 200, true], [1920, 1080]], (size, callback)=>
        #     this.process_version(size, callback)
        #   , (err, res)=>
        #     [@small, @large] = res
        #     this.upload(callback)
