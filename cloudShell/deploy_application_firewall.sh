#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
PROJECT=$(gcloud info --format='value(config.project)')
ZONE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" \
    -H "Metadata-Flavor: Google" | cut -d/ -f4)
INSTANCE_NAME="crypto-driver"

# Clone the professional-services repository
git clone https://github.com/GoogleCloudPlatform/professional-services.git

echo "Repository cloned successfully."

# Build the application using Maven
cd professional-services/examples/cryptorealtime
mvn clean install

echo "Application built successfully."

# Deploy the Dataflow pipeline
./run.sh ${PROJECT} cryptorealtime gs://realtimecrypto-${PROJECT}/temp cryptorealtime market

echo "Dataflow pipeline deployed successfully."

# Configure firewall to allow access to Flask frontend
gcloud compute firewall-rules create crypto-dashboard \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:5000 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=crypto-console \
    --description="Open port 5000 for crypto visualization tutorial"

echo "Firewall rule 'crypto-dashboard' created successfully."

# Tag the Compute Engine instance to apply the firewall rule
gcloud compute instances add-tags ${INSTANCE_NAME} \
    --tags="crypto-console" \
    --zone=${ZONE}

echo "Instance '${INSTANCE_NAME}' tagged with 'crypto-console' successfully."

# Navigate to the frontend directory and set up the Flask application
cd ../../frontend/
pip install -r requirements.txt
pip uninstall Flask Jinja2 -y
pip install Flask Jinja2

# Run the Flask application
python app.py ${PROJECT} cryptorealtime cryptorealtime market &

echo "Flask frontend application deployed successfully."

# Instructions to access the frontend
echo "To access the visualization, open a web browser and navigate to:"
echo "http://$(gcloud compute instances describe ${INSTANCE_NAME} --zone=${ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)'):5000"