module.exports =
  class TweetStatus
    constructor: (@tweet) ->

    isRetweeted: ->
      if @tweet.retweeted_status
        return true
      return false

    getRaw: ->
      @tweet

    getText: ->
      @tweet.text
