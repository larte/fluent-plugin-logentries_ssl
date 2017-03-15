# Logentries output plugin for [Fluentd](http://fluentd.org)

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

```
<match pattern>
  @type logentries_ssl
  token_path /path/to/tokens.yml
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

with tokens.yml
```
tag-to-send: [logentries tcp token]
other-tag: [other token]
```
Event tag must match key in tokens file.

other configuration keys:

| *parameter* | *descrtiption | *default value* |
|---|---|---|
| *le_host* | Logentries hostname to use  | data.logentries.com |
| *le_port* | Logentries port to use | 443 |
| *max_retries* | How many times event send is retried on errors | 3 |
| *json* | Send record as json | true |
| *verify_fqdn* | Verify FQDN for SSL | true |

## Copyright

* Copyright(c) 2017- larte
* License
  * Apache License, Version 2.0
