module.exports =
  class TweetStatus
    tweet: null
    ignoreRetweet: null

    constructor: (@tweet, options) ->
      {ignoreRetweet} = options
      @ignoreRetweet = ignoreRetweet

    isRetweeted: ->
      return true if @tweet.retweeted_status
      return false

    isStatusUpdateMessage: ->
      return true if @tweet.text
      return false

    isIgnored: ->
      return true unless @isStatusUpdateMessage()
      return true if @isRetweeted() and @ignoreRetweet
      return false

    getRaw: ->
      @tweet

    getText: ->
      @tweet.text
