#!/bin/bash

# Variables
AWS_REGION="ap-south-1"
ECR_REPOSITORY_NAME="flask-app"
IMAGE_NAME="flask-app"
TAG="latest"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECR repository URI
ECR_REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}"

# Ensure the ECR repository exists
aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "ECR repository does not exist. Creating repository ${ECR_REPOSITORY_NAME}."
  aws ecr create-repository --repository-name ${ECR_REPOSITORY_NAME}
else
  echo "ECR repository ${ECR_REPOSITORY_NAME} already exists."
fi

# Authenticate Docker to the ECR registry
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}


# Build the Docker image
docker build -t ${IMAGE_NAME}:${TAG} .

# Tag the Docker image with the ECR repository URI
docker tag ${IMAGE_NAME}:${TAG} ${ECR_REPOSITORY_URI}:${TAG}

# Push the Docker image to ECR
docker push ${ECR_REPOSITORY_URI}:${TAG}

echo "Docker image ${IMAGE_NAME}:${TAG} pushed to ${ECR_REPOSITORY_URI}:${TAG} successfully."
