#!/bin/bash
siege -c 250 -r 10000 -t 1M -d 0  -f urls.txt