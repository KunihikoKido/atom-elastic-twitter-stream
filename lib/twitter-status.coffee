module.exports =
  class TweetStatus
    tweet: null
    raw: null
    ignoreRetweet: false
    includeFields: null

    constructor: (@tweet, options) ->
      {ignoreRetweet, includeFields} = options
      @ignoreRetweet = ignoreRetweet
      @includeFields = includeFields
      @initialize?()

    initialize: ->
      @raw = @tweet
      @tweet.created_at = new Date(@tweet.created_at)
      item = {}
      for key, value of @tweet when key in @includeFields
        item[key] = value
      item.id = @tweet.id
      @tweet = item

    isRetweeted: ->
      return true if @raw.retweeted_status
      return false

    isStatusUpdateMessage: ->
      return true if @raw.text
      return false

    isIgnored: ->
      return true unless @isStatusUpdateMessage()
      return true if @isRetweeted() and @ignoreRetweet
      return false

    getText: ->
      return @raw.text

    getItem: ->
      return @tweet
