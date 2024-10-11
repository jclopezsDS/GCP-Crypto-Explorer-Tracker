#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Export project and zone variables
export PROJECT=$(gcloud info --format='value(config.project)')
export ZONE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" \
    -H "Metadata-Flavor: Google" | cut -d/ -f4)

# Enable necessary Google Cloud APIs
gcloud services enable bigtable.googleapis.com \
    bigtableadmin.googleapis.com \
    dataflow.googleapis.com \
    --project=${PROJECT}

echo "Required APIs enabled successfully."

# Create Bigtable instance
gcloud bigtable instances create cryptorealtime \
    --cluster=cryptorealtime-c1 \
    --cluster-zone=${ZONE} \
    --display-name=cryptorealtime \
    --cluster-storage-type=HDD \
    --instance-type=DEVELOPMENT

echo "Bigtable instance 'cryptorealtime' created successfully."

# Create Bigtable table with a column family
cbt -instance=cryptorealtime createtable cryptorealtime families=market

echo "Bigtable table 'cryptorealtime' with family 'market' created successfully."

# Create Google Cloud Storage bucket for Dataflow staging
gsutil mb -p ${PROJECT} gs://realtimecrypto-${PROJECT}

echo "Cloud Storage bucket 'gs://realtimecrypto-${PROJECT}' created successfully."