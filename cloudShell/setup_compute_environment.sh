#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
INSTANCE_NAME="crypto-driver"
ZONE="us-east1-c"
MACHINE_TYPE="n1-standard-1"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
BOOT_DISK_SIZE="20GB"

# Create the Compute Engine instance
gcloud beta compute instances create ${INSTANCE_NAME} \
    --zone=${ZONE} \
    --machine-type=${MACHINE_TYPE} \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=$(gcloud iam service-accounts list --format='value(email)' --filter="compute") \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --image-family=${IMAGE_FAMILY} \
    --image-project=${IMAGE_PROJECT} \
    --boot-disk-size=${BOOT_DISK_SIZE} \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=${INSTANCE_NAME}

echo "Compute Engine instance '${INSTANCE_NAME}' created successfully."

# Connect to the instance and configure the environment
gcloud compute ssh ${INSTANCE_NAME} --zone=${ZONE} --command="bash -s" <<'ENDSSH'
    set -e

    # Remove existing Google Cloud CLI
    sudo apt-get remove google-cloud-cli -y

    # Update system packages
    sudo apt-get update -y

    # Install Python3 and pip
    sudo apt install python3-pip -y

    # Install and set up virtualenv
    sudo pip3 install -U virtualenv
    virtualenv -p python3 venv
    source venv/bin/activate

    # Install required tools and specific versions of Google Cloud SDK and CBT
    sudo apt -y --allow-downgrades install openjdk-11-jdk git maven google-cloud-sdk=349.0.0-0 google-cloud-sdk-cbt=349.0.0-0

    echo "Environment configured successfully on '${HOSTNAME}'."
ENDSSH