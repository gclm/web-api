#!/bin/bash
set -e

mkdir -p /app/harPool
cd /app && nohup web-api & echo "启动成功"
