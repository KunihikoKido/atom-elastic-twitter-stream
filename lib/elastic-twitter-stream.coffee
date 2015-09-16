{CompositeDisposable} = require 'atom'
TweetStatus = require './twitter-status'
twitterConfig = require './twitter-config'
elasticConfig = require './elastic-config'
notifications = require './notifications'
twitterStream = require './twitter-stream'
loadingView = require './loading-view'


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
    return if twitterStream.isActive()

    elasticClient = new elasticConfig.Client()
    twitterClient = new twitterConfig.Client()

    params =
      language: twitterConfig.streamLanguage()
      follow: twitterConfig.streamFollow()
      track: twitterConfig.streamTrack()
      locations: twitterConfig.streamLocations()

    twitterClient.stream('statuses/filter', params, (stream) ->
      twitterStream.update(stream)

      stream.on('data', (tweet) ->
        tweetStatus = new TweetStatus(tweet)

        return if tweetStatus.isRetweeted() and twitterConfig.ignoreRetweet()

        loadingView.updateMessage(tweetStatus.getText())

        params =
          index: elasticConfig.index()
          type: elasticConfig.type()
          body: tweetStatus.getRaw()

        elasticClient.index(params).catch((error) ->
          twitterStream.destroy()
          loadingView.finish()
          notifications.addError("Elasticsearch Error", detail: error)
        )
      ).on('error', (error) ->
        twitterStream.destroy()
        loadingView.finish()
        notifications.addError("Twitter Stream Error", detail: error)
      )
    )

  stopCommand: ->
    twitterStream.destroy()
    loadingView.finish()
