angular.module('fileDrop', [])
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
