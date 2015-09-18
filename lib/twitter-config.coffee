Twitter = require 'twitter'

module.exports = TwitterConfig =
  consumerKey: ->
    atom.config.get('elastic-twitter-stream.twitterConsumerKey')
  consumerSecret: ->
    atom.config.get('elastic-twitter-stream.twitterConsumerSecret')
  accessTokenKey: ->
    atom.config.get('elastic-twitter-stream.twitterAccessTokenKey')
  accessTokenSecret: ->
    atom.config.get('elastic-twitter-stream.twitterAccessTokenSecret')
  ignoreRetweet: ->
    atom.config.get('elastic-twitter-stream.twitterIgnoreRetweet')
  includeFields: ->
    atom.config.get('elastic-twitter-stream.twitterIncludeFields')
  streamFollow: ->
    atom.config.get('elastic-twitter-stream.twitterStreamFollow')
  streamTrack: ->
    atom.config.get('elastic-twitter-stream.twitterStreamTrack')
  streamLocations: ->
    atom.config.get('elastic-twitter-stream.twitterStreamLocations')
  streamLanguage: ->
    atom.config.get('elastic-twitter-stream.twitterStreamLanguage')
  timeout: ->
    atom.config.get('elastic-twitter-stream.twitterTimeout')
  Client: ->
    Twitter(
      consumer_key: TwitterConfig.consumerKey()
      consumer_secret: TwitterConfig.consumerSecret()
      access_token_key: TwitterConfig.accessTokenKey()
      access_token_secret: TwitterConfig.accessTokenSecret()
    )
