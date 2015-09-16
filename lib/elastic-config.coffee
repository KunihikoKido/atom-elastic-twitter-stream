{allowUnsafeNewFunction} = require 'loophole'
elasticsearch = allowUnsafeNewFunction -> require 'elasticsearch'

module.exports = ElasticConfig =
  host: ->
    atom.config.get('elastic-twitter-stream.elasticsearchHost')
  index: ->
    atom.config.get('elastic-twitter-stream.elasticsearchIndex')
  type: ->
    atom.config.get('elastic-twitter-stream.elasticsearchType')
  bulkSize: ->
    atom.config.get('elastic-twitter-stream.elasticsearchBulkSize')
  flushInterval: ->
    atom.config.get('elastic-twitter-stream.elasticsearchFlushInterval')
  Client: ->
    elasticsearch.Client(host: ElasticConfig.host())
