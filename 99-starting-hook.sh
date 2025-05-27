#!/bin/sh

# chown the mount to allow the www-data user read and write access.
chown -R rocketmq:rocketmq /home/rocketmq/store && echo "✅ added permissions to mounted volume"