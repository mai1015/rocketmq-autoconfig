# Use the official Apache RocketMQ base image
FROM apache/rocketmq:5.3.3

USER root

# Install the 'ip' command.
RUN apt update && \
    apt install -y iproute2 && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 ./99-starting-hook.sh /etc/entrypoint.d/99-starting-hook.sh

USER rocketmq

COPY --chown=rocketmq:rocketmq broker.conf /home/rocketmq/broker.conf

COPY --chown=rocketmq:rocketmq configure.sh /home/rocketmq/configure.sh

RUN chmod +x /home/rocketmq/configure.sh
