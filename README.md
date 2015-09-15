# elastic-twitter-stream package

Twitter Stream to Elasticsearch.


## Prerequisites
You need to get an OAuth token in order to use elastic-twitter-stream package. Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom),

## Settings for Twitter Stream API
### Twitter Consumer Key
Your Consumer Key. default to ''

### Twitter Consumer Secret
Your Consumer Secret. default to ''

### Twitter Access Token Key
Your Access Token Key. default to ''

### Twitter Access Token Secret
Your Access Token Secret. default to ''

### Twitter Ignore Retweet
If you don't want to index retweets, just set this option to `true`. default to `false`

### Twitter Stream Follow
A comma separated list of user IDs, indicating the users to return statuses for in the stream. See [follow](https://dev.twitter.com/streaming/overview/request-parameters#follow) for more information. default to ''

### Twitter Stream Locations
Specifies a set of bounding boxes to track. See [locations](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to ''

### Twitter Stream Track
Keywords to track. Phrases of keywords are specified by a comma-separated list. See [track](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to 'twitter'

### Twitter Stream Language
Setting this parameter to a comma-separated list of BCP 47 language identifiers. See [language](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to ''

## Settings for Elasticsearch
### Elasticsearch Host
default to 'http://localhost:9200'
### Elasticsearch Index
default to 'twitter'
### Elasticsearch Type
default to 'tweets'

## Commands
### Elastic Twitter Stream: Start
Start Twitter Stream to Elasticsearch.
### Elastic Twitter Stream: Stop
Stop Twitter Stream to Elasticsearch.
