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
      title: 'Twitter - Consumer key'
      description: """
        You need to get an OAuth token in order to use elastic-twitter-stream package.
        Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom)
        """
    twitterConsumerSecret:
      type: 'string'
      default: ''
      title: 'Twitter - Consumer secret'
      description: """
        You need to get an OAuth token in order to use elastic-twitter-stream package.
        Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom)
        """
    twitterAccessTokenKey:
      type: 'string'
      default: ''
      title: 'Twitter - Access token key'
      description: """
        You need to get an OAuth token in order to use elastic-twitter-stream package.
        Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom)
        """
    twitterAccessTokenSecret:
      type: 'string'
      default: ''
      title: 'Twitter - Access token secret'
      description: """
        You need to get an OAuth token in order to use elastic-twitter-stream package.
        Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom)
        """
    twitterIgnoreRetweet:
      type: 'boolean'
      default: false
      title: 'Twitter - Ignore retweet'
    twitterStreamFollow:
      type: 'string'
      default: ''
      title: 'Twitter - Filter stream follow option'
      description: """
        A comma separated list of user IDs, indicating the users to return statuses for in the stream.
        See [follow](https://dev.twitter.com/streaming/overview/request-parameters#follow) for more information.
        """
    twitterStreamTrack:
      type: 'string'
      default: 'twitter'
      title: 'Twitter - Filter stream track option'
      description: """
        Keywords to track. Phrases of keywords are specified by a comma-separated list.
        See [track](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information.
        """
    twitterStreamLocations:
      type: 'string'
      default: ''
      title: 'Twitter - Filter stream locations option'
      description: """
        Specifies a set of bounding boxes to track.
        See [locations](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information.
        """
    twitterStreamLanguage:
      type: 'string'
      default: ''
      title: 'Twitter - Filter stream language option'
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
      title: 'Twitter - Include fields'
      description: """
        A comma-separated list of include fields.
        See [Tweets field guide](https://dev.twitter.com/overview/api/tweets) more information.
        """
    twitterTimeout:
      type: 'integer'
      default: 0
      title: 'Twitter - Timeout'
      description: """
        If you automatically to stop the stream of Twitter , you set the time-out .
        * The timeout in seconds
        """
    elasticsearchHost:
      type: 'string'
      default: 'http://localhost:9200'
      title: 'Elasticsearch - Host'
    elasticsearchIndex:
      type: 'string'
      default: 'twitter'
      title: 'Elasticsearch - Index'
    elasticsearchType:
      type: 'string'
      default: 'tweets'
      title: 'Elasticsearch - Type'
    elasticsearchBulkSize:
      type: 'integer'
      default: 100
      title: 'Elasticsearch - Bulk size'
    elasticsearchFlushInterval:
      type: 'integer'
      default: 5
      title: 'Elasticsearch - Flush interval'
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

    options =
      timeout: twitterConfig.timeout()
    twitterStream.setTimeout(stopTwitterStream, options)

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
        stopTwitterStream()
        notifications.addError("Twitter Stream Error", detail: error)
      )
    )

  stopCommand: ->
    stopTwitterStream()


stopTwitterStream = ->
  twitterStream.destroy()
  loadingView.finish()


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
    stopTwitterStream()
    notifications.addError("Elasticsearch Error", detail: error)
  )
