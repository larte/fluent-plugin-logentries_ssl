# Logentries output plugin for [Fluentd](http://fluentd.org)
[![Build Status](https://travis-ci.org/larte/fluent-plugin-logentries_ssl.png)](https://travis-ci.org/larte/fluent-plugin-logentries_ssl.png)
[![Coverage Status](https://coveralls.io/repos/github/larte/fluent-plugin-logentries_ssl/badge.svg)](https://coveralls.io/github/larte/fluent-plugin-logentries_ssl)

## Overview

Buffer and perioidically send event logs to [Logentries](http://logentries.com). It sends whole record as json, if
a logentries TCP token is configured for the tag.


## Reguirements

* fluentd >= v0.14.0
* ruby >= 2.1

## Installation

```
gem install fluent-plugin-logentries_ssl
```

## Configuration

One of parameters *token\_path* or *default\_token* must be given. if token path is not defined, the Logentries token *default\_token* is used for all fluent events. When using *default\_token* with tokens from *token\_path*, it will be used as a fallback after trying to match a tag to a token in *token\_path*.

| *parameter* | *description | *default value* |
|---|---|---|
| *token_path* | Path to YAML formatted file containing 'tag: logentries-token' pairs | nil |
| *default_token* | A token string to be used either for all tags, or as fallback after token_path| nil |


```
<match pattern>
  @type logentries_ssl
  token_path /path/to/tokens.yml
</match>
```

or with *default\_token*:

```
<match pattern>
  @type logentries_ssl
  token_path /path/to/tokens.yml
  default_token 'aaa-bbb-ccc'
</match>
```

```
<match pattern>
  @type logentries_ssl
  token_path /path/to/tokens.yml
  <buffer>
    @type file
    path /path/to_le_buffer.*.buffer
    flush_interval 5s
    flush_at_shutdown true
  </buffer>
</match>

````
with tokens.yml

```
tag-to-send: [logentries tcp token]
other-tag: [other token]
```

Event tag must match key in tokens file.

other configuration keys:

| *parameter* | *description | *default value* |
|---|---|---|
| *le_host* | Logentries hostname to use  | data.logentries.com |
| *le_port* | Logentries port to use | 443 |
| *max_retries* | How many times event send is retried on errors | 3 |
| *json* | Send record as json | true |
| *verify_fqdn* | Verify FQDN for SSL | true |


## Alternatives

* [fluent-plugin-logentries](https://github.com/Woorank/fluent-plugin-logentries)
* [fluent-plugin-simple-logentries](https://github.com/sowawa/fluent-plugin-simple-logentries)

## Copyright

* Copyright(c) 2017- larte
* License
  * Apache License, Version 2.0
