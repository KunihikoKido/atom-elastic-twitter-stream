module.exports = TwitterStream =
  currentStream: null
  items: []
  intervalId: null
  bulkSize: 100
  callback: null

  isActive: ->
    if @currentStream
      return true
    return false

  isEmptyItems: ->
    if @items.length is 0
      return true
    return false

  addItem: (tweet) ->
    @items.push(tweet)
    @callback() if @items.length >= @bulkSize

  resetItems: ->
    @items = []

  getItems: ->
    @items

  updateCurrentStream: (stream) ->
    @currentStream = stream

  destroy: ->
    @callback() unless @isEmptyItems()
    @currentStream?.destroy()
    @currentStream = null
    clearInterval(@intervalId) if @intervalId

  setInterval: (@callback, options) ->
    {flushInterval, bulkSize} = options
    @bulkSize = bulkSize
    @intervalId = setInterval(callback, flushInterval)
