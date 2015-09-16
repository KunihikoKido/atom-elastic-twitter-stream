{allowUnsafeNewFunction} = require 'loophole'
elasticsearch = allowUnsafeNewFunction -> require 'elasticsearch'

module.exports = ElasticConfig =
  host: ->
    atom.config.get('elastic-twitter-stream.elasticsearchHost')
  index: ->
    atom.config.get('elastic-twitter-stream.elasticsearchIndex')
  type: ->
    atom.config.get('elastic-twitter-stream.elasticsearchType')
  Client: ->
    elasticsearch.Client(host: ElasticConfig.host())
