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

## Test 1

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

```sh
Completed 32000 requests
Finished 32000 requests


Server Software:
Server Hostname:        127.0.0.1
Server Port:            3000

Document Path:          /register
Document Length:        0 bytes

Concurrency Level:      150
Time taken for tests:   61.102 seconds
Complete requests:      32000
Failed requests:        0
Total transferred:      10016000 bytes
Total body sent:        5440000
HTML transferred:       0 bytes
Requests per second:    523.71 [#/sec] (mean)
Time per request:       286.417 [ms] (mean)
Time per request:       1.909 [ms] (mean, across all concurrent requests)
Transfer rate:          160.08 [Kbytes/sec] received
                        86.94 kb/s sent
                        247.02 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   63 918.7      0   13788
Processing:     4  222  60.0    206     787
Waiting:        4  221  58.7    205     778
Total:          4  286 918.5    206   13897

Percentage of the requests served within a certain time (ms)
  50%    206
  66%    218
  75%    232
  80%    242
  90%    287
  95%    347
  98%    390
  99%    506
 100%  13897 (longest request)
```