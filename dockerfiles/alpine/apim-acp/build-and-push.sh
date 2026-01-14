#!/bin/bash

# Build and push WSO2 API Manager ACP Docker image to Google Cloud registries
# with required Google Cloud Marketplace annotation
set -e

# Configuration
GCP_SERVICE_NAME="services/wso2-apimanager.endpoints.wso2-marketplace-public.cloud.goog"

# Registry and image configurations
REGISTRY_1="us-docker.pkg.dev"
REGISTRY_2="us-east1-docker.pkg.dev"
PROJECT_REPO="wso2-marketplace-public/wso2-marketplace"
IMAGE_NAME="wso2am-acp"

# Tags to push
TAG_1="4.5.0"
TAG_2="4.5"

echo "======================================"
echo "Building WSO2 APIM ACP for GCP Marketplace"
echo "======================================"
echo "Service: ${GCP_SERVICE_NAME}"
echo ""
echo "Will push to:"
echo "  - ${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}"
echo "  - ${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}"
echo "  - ${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}"
echo "  - ${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}"
echo ""

# Check if buildx is available
if ! docker buildx version &> /dev/null; then
    echo "❌ Error: docker buildx is not available"
    exit 1
fi

# Ensure gcp-builder is active
echo "Setting up buildx builder..."
docker buildx use gcp-builder 2>/dev/null || {
    docker buildx create --name gcp-builder --driver docker-container --driver-opt network=host --use
    docker buildx inspect --bootstrap
}

echo ""
echo "======================================"
echo "Building and pushing to us-docker.pkg.dev"
echo "======================================"

# Build and push to us-docker.pkg.dev with tag 4.5.0
echo ""
echo "Pushing ${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}..."
docker buildx build \
  --platform linux/amd64 \
  --push \
  --annotation "index:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --annotation "manifest:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --tag "${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}" \
  .

# Build and push to us-docker.pkg.dev with tag 4.5
echo ""
echo "Pushing ${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}..."
docker buildx build \
  --platform linux/amd64 \
  --push \
  --annotation "index:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --annotation "manifest:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --tag "${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}" \
  .

echo ""
echo "======================================"
echo "Building and pushing to us-east1-docker.pkg.dev"
echo "======================================"

# Build and push to us-east1-docker.pkg.dev with tag 4.5.0
echo ""
echo "Pushing ${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}..."
docker buildx build \
  --platform linux/amd64 \
  --push \
  --annotation "index:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --annotation "manifest:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --tag "${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1}" \
  .

# Build and push to us-east1-docker.pkg.dev with tag 4.5
echo ""
echo "Pushing ${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}..."
docker buildx build \
  --platform linux/amd64 \
  --push \
  --annotation "index:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --annotation "manifest:com.googleapis.cloudmarketplace.product.service.name=${GCP_SERVICE_NAME}" \
  --tag "${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_2}" \
  .

echo ""
echo "✓ All builds completed successfully!"
echo ""
echo "======================================"
echo "Verify Annotations:"
echo "======================================"
echo "docker buildx imagetools inspect ${REGISTRY_1}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1} --raw | jq '.annotations'"
echo "docker buildx imagetools inspect ${REGISTRY_2}/${PROJECT_REPO}/${IMAGE_NAME}:${TAG_1} --raw | jq '.annotations'"
echo ""
