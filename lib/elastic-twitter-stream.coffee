{CompositeDisposable} = require 'atom'
{allowUnsafeNewFunction} = require 'loophole'
elasticsearch = allowUnsafeNewFunction -> require 'elasticsearch'
Twitter = require 'twitter'
LoadingView = require './loading-view'

twitterConfig =
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
  streamFollow: ->
    atom.config.get('elastic-twitter-stream.twitterStreamFollow')
  streamTrack: ->
    atom.config.get('elastic-twitter-stream.twitterStreamTrack')
  streamLocations: ->
    atom.config.get('elastic-twitter-stream.twitterStreamLocations')
  streamLanguage: ->
    atom.config.get('elastic-twitter-stream.twitterStreamLanguage')
  streamParameters: ->
    params =
      language: twitterConfig.streamLanguage()
      follow: twitterConfig.streamFollow()
      track: twitterConfig.streamTrack()
      locations: twitterConfig.streamLocations()
    return params
  Client: ->
    Twitter(
      consumer_key: twitterConfig.consumerKey()
      consumer_secret: twitterConfig.consumerSecret()
      access_token_key: twitterConfig.accessTokenKey()
      access_token_secret: twitterConfig.accessTokenSecret()
    )


elasticConfig =
  host: ->
    atom.config.get('elastic-twitter-stream.elasticsearchHost')
  index: ->
    atom.config.get('elastic-twitter-stream.elasticsearchIndex')
  type: ->
    atom.config.get('elastic-twitter-stream.elasticsearchType')
  indexParameters: (tweet) ->
    params =
      index: elasticConfig.index()
      type: elasticConfig.type()
      body: tweet
    return params
  Client: ->
    elasticsearch.Client(host: elasticConfig.host())


notifications =
  packageName: 'Elastic Twitter Stream'
  addInfo: (message, {detail}={}) ->
    atom.notifications?.addInfo("#{@packageName}: #{message}", detail: detail)
  addError: (message, {detail}={}) ->
    atom.notifications.addError(
      "#{@packageName}: #{message}", detail: detail, dismissable: true)


currentTwitterStream = null
loadingView = null

destroyTwitterStream = ->
  currentTwitterStream?.destroy()
  currentTwitterStream = null
  loadingView?.finish()
  loadingView = null

ignoreTweet = (tweet) ->
  if tweet.retweeted_status and twitterConfig.ignoreRetweet()
    return true
  return false


module.exports = ElasticsearchTwitter =
  subscriptions: null

  config:
    twitterConsumerKey:
      type: 'string'
      default: ''
    twitterConsumerSecret:
      type: 'string'
      default: ''
    twitterAccessTokenKey:
      type: 'string'
      default: ''
    twitterAccessTokenSecret:
      type: 'string'
      default: ''
    twitterIgnoreRetweet:
      type: 'boolean'
      default: false
    twitterStreamFollow:
      type: 'string'
      default: ''
      description: """
        A comma-separated list of user IDs.\n
        See https://dev.twitter.com/streaming/overview/request-parameters#follow
        """
    twitterStreamTrack:
      type: 'string'
      default: 'twitter'
      description: """
        A comma-separated list of phrases.\n
        See https://dev.twitter.com/streaming/overview/request-parameters#track
        """
    twitterStreamLocations:
      type: 'string'
      default: ''
      description: """
        A comma-separated list of longitude,latitude pairs.\n
        See https://dev.twitter.com/streaming/overview/request-parameters#locations
        """
    twitterStreamLanguage:
      type: 'string'
      default: ''
      description: """
        A comma-separated list of BCP 47 language identifiers.\n
        See https://dev.twitter.com/streaming/overview/request-parameters#language
        """
    elasticsearchHost:
      type: 'string'
      default: 'http://localhost:9200'
    elasticsearchIndex:
      type: 'string'
      default: 'twitter'
    elasticsearchType:
      type: 'string'
      default: 'tweets'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'elastic-twitter-stream:start': => @startCommand()
    @subscriptions.add atom.commands.add 'atom-workspace', 'elastic-twitter-stream:stop': => @stopCommand()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  startCommand: ->
    return if currentTwitterStream

    loadingView = new LoadingView()
    elasticClient = new elasticConfig.Client()
    twitterClient = new twitterConfig.Client()

    twitterClient.stream('statuses/filter', twitterConfig.streamParameters(), (stream) ->
      currentTwitterStream = stream

      stream.on('data', (tweet) ->
        return if ignoreTweet(tweet)

        loadingView.updateMessage(tweet.text)

        elasticClient.index(elasticConfig.indexParameters(tweet)).catch((error) ->
          destroyTwitterStream()
          notifications.addError("Elasticsearch Error", detail: error)
        )
      )

      stream.on('error', (error) ->
        destroyTwitterStream()
        notifications.addError("Twitter Stream Error", detail: error)
      )
    )

  stopCommand: ->
    destroyTwitterStream()
