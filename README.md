# elastic-twitter-stream package

Twitter Stream to Elasticsearch.

![overview](https://raw.githubusercontent.com/KunihikoKido/atom-elastic-twitter-stream/master/screenshots/overview.gif)

## Prerequisites
You need to get an OAuth token in order to use elastic-twitter-stream package. Please follow  [Twitter documentation](https://dev.twitter.com/docs/auth/tokens-devtwittercom),

## Settings for Twitter Stream API
### Consumer key
Your Consumer Key. default to ''

### Consumer secret
Your Consumer Secret. default to ''

### Access token key
Your Access Token Key. default to ''

### Access token secret
Your Access Token Secret. default to ''

### Ignore retweet
If you don't want to index retweets, just set this option to `true`. default to `false`

### Include fields
A comma-separated list of include fields. See [Tweets field guide](https://dev.twitter.com/overview/api/tweets). default to all fields included.

### Filter stream follow option
A comma separated list of user IDs, indicating the users to return statuses for in the stream. See [follow](https://dev.twitter.com/streaming/overview/request-parameters#follow) for more information. default to ''

### Filter stream locations option
Specifies a set of bounding boxes to track. See [locations](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to ''

### Filter stream track option
Keywords to track. Phrases of keywords are specified by a comma-separated list. See [track](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to 'twitter'

### Filter stream language option
Setting this parameter to a comma-separated list of BCP 47 language identifiers. See [language](https://dev.twitter.com/streaming/overview/request-parameters#track) for more information. default to ''

## Settings for Elasticsearch
### Host
default to 'http://localhost:9200'
### Index
default to 'twitter'
### Type
default to 'tweets'
### Bulk size
default to 100
### Flush interval
default to 5 (5s)

## Commands
### Elastic Twitter Stream: Start
Start Twitter Stream to Elasticsearch.
### Elastic Twitter Stream: Stop
Stop Twitter Stream to Elasticsearch.
