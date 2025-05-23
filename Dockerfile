# Use the official Apache RocketMQ base image
FROM apache/rocketmq:5.3.3

# Install the 'ip' command.
RUN apt-get update && \
    apt-get install -y iproute2 && \
    rm -rf /var/lib/apt/lists/*

COPY broker.conf /home/rocketmq/broker.conf

COPY configure.sh /home/rocketmq/configure.sh
RUN chmod +x /home/rocketmq/configure.sh