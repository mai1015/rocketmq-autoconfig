#!/bin/bash

# This script fetches the container's IPv6 address and configures
# brokerIP1 in the RocketMQ broker.conf file.
# It also configures the brokerName from the BROKERNAME environment variable,
# targeting the <BROKERNAME> placeholder.

# Define the path to the broker.conf file
BROKER_CONF_FILE="/home/rocketmq/broker.conf"
#NETWORK_INTERFACE="railnet0"

# --- Function to get the container's IPv6 address ---
# This function attempts to find a global unicast IPv6 address
# associated with the 'eth0' interface within the Docker container.
get_ipv6_address() {
  # Use 'ip -6 addr show eth0' to list IPv6 addresses for eth0.
  # 'grep inet6' filters for lines with IPv6 addresses.
  # 'awk '{print $2}'' extracts the address/prefix.
  # 'cut -d/ -f1' removes the CIDR suffix (e.g., /64).
  # 'grep -v fe80' excludes link-local addresses.
  # 'head -n 1' takes only the first found address.
  ip -6 addr show $NETWORK_INTERFACE | \
    grep inet6 | \
    awk '{print $2}' | \
    cut -d/ -f1 | \
    grep -v fe80 | \
    head -n 1
}

if [ -z "$NETWORK_INTERFACE" ]; then
  echo "Error: NETWORK_INTERFACE environment variable is not set. Using default value."
  NETWORK_INTERFACE="railnet0"
else
  echo "NETWORK_INTERFACE environment variable found: $NETWORK_INTERFACE"
fi

# Fetch the IPv6 address
IP_ADDRESS=$(get_ipv6_address)

# Check if an IPv6 address was successfully fetched
if [ -z "$IP_ADDRESS" ]; then
  echo "Error: Could not determine IPv6 address for the container."
  echo "Please ensure IPv6 networking is enabled for your Docker daemon and container."
  exit 1
fi

# Fetch the broker name from the environment variable
if [ -z "$BROKERNAME" ]; then
  #echo "Error: BROKERNAME environment variable is not set. Using default value."
  # add borker- prefix to the machine name
  BROKERNAME="broker-$(hostname)"  # Default value if not set
else
  echo "BROKERNAME environment variable found: $BROKERNAME"
fi

# Check if the broker.conf file exists
if [ ! -f "$BROKER_CONF_FILE" ]; then
  echo "Error: broker.conf file not found at $BROKER_CONF_FILE."
  echo "Please ensure the file exists before running this script."
  exit 1
fi

# Use sed to replace the placeholder with the fetched IPv6 address
sed -i "s/^brokerIP1 = <IPADDRESS>/brokerIP1 = $IP_ADDRESS/" "$BROKER_CONF_FILE"

if [ $? -eq 0 ]; then
  echo "Successfully updated brokerIP1 to $IP_ADDRESS in $BROKER_CONF_FILE"
else
  echo "Error: Failed to update brokerIP1 in $BROKER_CONF_FILE"
  exit 1
fi

# Update brokerName using the BROKERNAME environment variable
sed -i "s/^brokerName = <BROKERNAME>/brokerName = $BROKERNAME/" "$BROKER_CONF_FILE"

if [ $? -eq 0 ]; then
  echo "Successfully updated brokerName to $BROKERNAME in $BROKER_CONF_FILE"
else
  echo "Error: Failed to update brokerName in $BROKER_CONF_FILE"
  exit 1
fi

echo "New content of broker.conf:"
cat "$BROKER_CONF_FILE"

# Start the broker
echo "Starting the broker..."
/home/rocketmq/bin/mqbroker -c $BROKER_CONF_FILE