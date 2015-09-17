{CompositeDisposable} = require 'atom'
TweetStatus = require './twitter-status'
twitterConfig = require './twitter-config'
elasticConfig = require './elastic-config'
notifications = require './notifications'
twitterStream = require './twitter-stream'
loadingView = require './loading-view'

bulkIndex = ->
  return if twitterStream.isEmptyItems()

  client = new elasticConfig.Client()

  params =
    index: elasticConfig.index()
    type: elasticConfig.type()
    body: []

  for item in twitterStream.getItems()
    action = index: {}
    action.index._id = item.id
    params.body.push(action, item)
  twitterStream.resetItems()

  client.bulk(params).catch((error) ->
    twitterStream.destroy()
    loadingView.finish()
    notifications.addError("Elasticsearch Error", detail: error)
  )


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
        A comma separated list of user IDs, indicating the users to return statuses for in the stream.
        See [follow](https://dev.twitter.com/streaming/overview/request-parameters#follow) for more information.
        """
    twitterStreamTrack:
      type: 'string'
      default: 'twitter'
      description: """
        Keywords to track. Phrases of keywords are specified by a comma-separated list.
        See [track](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information.
        """
    twitterStreamLocations:
      type: 'string'
      default: ''
      description: """
        Specifies a set of bounding boxes to track.
        See [locations](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information.
        """
    twitterStreamLanguage:
      type: 'string'
      default: ''
      description: """
        Setting this parameter to a comma-separated list of BCP 47 language identifiers.
        See [language](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information.
        """
    twitterIncludeFields:
      type: 'array'
      default: [
        'annotations',
        'contributors',
        'coordinates',
        'created_at',
        'current_user_retweet',
        'entities',
        'favorite_count',
        'favorited',
        'filter_level',
        'geo',
        'id',
        'id_str',
        'in_reply_to_screen_name',
        'in_reply_to_status_id',
        'in_reply_to_status_id_str',
        'in_reply_to_user_id',
        'in_reply_to_user_id_str',
        'lang',
        'place',
        'possibly_sensitive',
        'quoted_status_id',
        'quoted_status_id_str',
        'quoted_status',
        'scopes',
        'retweet_count',
        'retweeted',
        'retweeted_status',
        'source',
        'text',
        'truncated',
        'user',
        'withheld_copyright',
        'withheld_in_countries',
        'withheld_scope'
      ]
      description: """
        A comma-separated list of include fields.
        See [Tweets field guide](https://dev.twitter.com/overview/api/tweets) more information.
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
    elasticsearchBulkSize:
      type: 'integer'
      default: 100
    elasticsearchFlushInterval:
      type: 'integer'
      default: 5
      description: 'The flush interval in seconds'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'elastic-twitter-stream:start': => @startCommand()
    @subscriptions.add atom.commands.add 'atom-workspace', 'elastic-twitter-stream:stop': => @stopCommand()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  startCommand: ->
    return if twitterStream.isActive()

    options =
      flushInterval: elasticConfig.flushInterval()
      bulkSize: elasticConfig.bulkSize()

    twitterStream.setInterval(bulkIndex, options)

    loadingView.updateMessage("Start twitter stream to elasticsearch ...")

    client = new twitterConfig.Client()

    params =
      language: twitterConfig.streamLanguage()
      follow: twitterConfig.streamFollow()
      track: twitterConfig.streamTrack()
      locations: twitterConfig.streamLocations()

    client.stream('statuses/filter', params, (stream) ->
      twitterStream.updateCurrentStream(stream)

      stream.on('data', (tweet) ->
        options =
          ignoreRetweet: twitterConfig.ignoreRetweet()
          includeFields: twitterConfig.includeFields()
        tweetStatus = new TweetStatus(tweet, options)

        return if tweetStatus.isIgnored()

        loadingView.updateMessage(tweetStatus.getText())
        twitterStream.addItem(tweetStatus.getItem())
      ).on('error', (error) ->
        twitterStream.destroy()
        loadingView.finish()
        notifications.addError("Twitter Stream Error", detail: error)
      )
    )

  stopCommand: ->
    twitterStream.destroy()
    loadingView.finish()
