module.exports = TwitterStream =
  currentStream: null

  isActive: ->
    if @currentStream
      return true
    return false

  update: (stream) ->
    @currentStream = stream

  destroy: ->
    @currentStream?.destroy()
    @currentStream = null
