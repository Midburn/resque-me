# Siege Test


## Preparation:

* Installation (OSX)

```sh
$ sudo gem install bundler
$ brew install siege
$ brew install ab
$ brew install redis-server
$ brew install redis-cli
$ brew install redis-browser
$ redis-server
$ redis-browser
$ redis-cli
```

* Flush Redis between tests

```sh
$ redis-cli
127.0.0.1:6379> FLUSHALL
OK
```
* Start Puma in midburn-queue root
```sh
$ cp .env-example .env
$ sed -i -- 's/redis:623e9c0cb0a185b9cac9b3c8geal3812@joe.redis.com:12345/localhost:6379/g' .env
$ bundle install
$ bundle exec rake midburn:open_queue
$ bundle exec puma -p 3000 -C puma.rb
```

# Machine

  Model Name:	MacBook Pro
  Model Identifier:	MacBookPro8,3
  Processor Name:	Intel Core i7
  Processor Speed:	2.2 GHz
  Number of Processors:	1
  Total Number of Cores:	4
  Memory:	16 GB

# Server

```sh
Puma starting in single mode...

Version 2.16.0 (ruby 2.2.3-p173), codename: Midwinter Nights Trance
Min threads: 20, max threads: 60
Environment: development 
Listening on tcp://0.0.0.0:3000
```

# Siege

* Sinatra Results

```sh
$ cd benchmark
$ siege -c 250 -r 1000 -t 1M -d 0  -f urls.txt
...
Lifting the server siege...      done.

Transactions:		       31270 hits
Availability:		      100.00 %
Elapsed time:		       59.61 secs
Data transferred:	        0.00 MB
Response time:		        0.47 secs
Transaction rate:	      524.58 trans/sec
Throughput:		        0.00 MB/sec
Concurrency:		      247.94
Successful transactions:       31270
Failed transactions:	           0
Longest transaction:	       14.47
Shortest transaction:	        0.00
```

* Node Results:

```sh
Lifting the server siege...      done.

Transactions:		       32895 hits
Availability:		       99.19 %
Elapsed time:		       59.03 secs
Data transferred:	        0.50 MB
Response time:		        0.39 secs
Transaction rate:	      557.26 trans/sec
Throughput:		        0.01 MB/sec
Concurrency:		      218.83
Successful transactions:       32895
Failed transactions:	         267
Longest transaction:	       20.03
Shortest transaction:	        0.00
```


## redis-cli:
```sh
127.0.0.1:6379> FLUSHALL
OK
127.0.0.1:6379> LLEN resque:queue:tickets_queue
(integer) 0
127.0.0.1:6379> LLEN resque:queue:tickets_queue
(integer) 31519
```

# Apache Benchmark Test

* Installation (OSX) 

```sh
$ brew install ab
```

* Run the test

```sh
$ ab -n 32000 -c 150 -T 'application/json' -p post.json -v 1 http://127.0.0.1:3000/register
```

## Results

* Sinatra Results

```sh
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 3200 requests
Completed 6400 requests
Completed 9600 requests
Completed 12800 requests
Completed 16000 requests
Completed 19200 requests
Completed 22400 requests
Completed 25600 requests
Completed 28800 requests
Completed 32000 requests
Finished 32000 requests


Server Software:
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /register
Document Length:        0 bytes

Concurrency Level:      100
Time taken for tests:   56.068 seconds
Complete requests:      32000
Failed requests:        0
Total transferred:      10016000 bytes
Total body sent:        5632000
HTML transferred:       0 bytes
Requests per second:    570.73 [#/sec] (mean)
Time per request:       175.214 [ms] (mean)
Time per request:       1.752 [ms] (mean, across all concurrent requests)
Transfer rate:          174.45 [Kbytes/sec] received
                        98.09 kb/s sent
                        272.55 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   42 744.6      0   13344
Processing:     2  133  46.8    121     431
Waiting:        2  132  44.4    121     431
Total:          2  175 742.7    122   13712

Percentage of the requests served within a certain time (ms)
  50%    122
  66%    126
  75%    130
  80%    133
  90%    141
  95%    279
  98%    325
  99%    359
 100%  13712 (longest request)
```

* Node Results:

```sh
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 3200 requests
Completed 6400 requests
Completed 9600 requests
Completed 12800 requests
Completed 16000 requests
Completed 19200 requests
Completed 22400 requests
Completed 25600 requests
Completed 28800 requests
Completed 32000 requests
Finished 32000 requests


Server Software:
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /register
Document Length:        16 bytes

Concurrency Level:      100
Time taken for tests:   45.702 seconds
Complete requests:      32000
Failed requests:        0
Total transferred:      13056000 bytes
Total body sent:        5632000
HTML transferred:       512000 bytes
Requests per second:    700.19 [#/sec] (mean)
Time per request:       142.817 [ms] (mean)
Time per request:       1.428 [ms] (mean, across all concurrent requests)
Transfer rate:          278.98 [Kbytes/sec] received
                        120.35 kb/s sent
                        399.33 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   63 1105.9      1   19979
Processing:     2   80  53.8     63     531
Waiting:        2   75  50.9     59     528
Total:          2  143 1112.5     64   20151

Percentage of the requests served within a certain time (ms)
  50%     64
  66%     71
  75%     78
  80%     87
  90%    117
  95%    164
  98%    323
  99%    399
 100%  20151 (longest request)
```


```sh
127.0.0.1:6379> FLUSHALL
OK
127.0.0.1:6379> HLEN rsmq:tickets-queue:Q
(integer) 0
127.0.0.1:6379> HLEN rsmq:tickets-queue:Q
(integer) 32006
```