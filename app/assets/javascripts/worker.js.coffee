# worker = new Worker('/assets/worker.js')
# worker.addEventListener('message', ((event)->
#   console.log 'FROM WORKER'
#   console.log event
# ), false)
# worker.postMessage('Hello')
@.addEventListener('message', ((event)->
  @postMessage('Plop' + event.data)
), false)
