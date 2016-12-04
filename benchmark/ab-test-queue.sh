#!/bin/bash
ab -n 32000 -c 150 -T 'application/json' -p post.json -v 1 http://127.0.0.1:3000/register