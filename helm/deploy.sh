#!/bin/bash

set -e

echo "========================================="
echo "Starting deployment to retail-app namespace"
echo "========================================="

# Authenticate with EKS cluster
echo "Authenticating with EKS cluster..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

echo "Testing cluster connection..."
kubectl get nodes

echo "Logging into Public ECR..."
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

# Helper function to deploy helm chart
deploy_chart() {
  RELEASE_NAME=$1
  CHART=$2
  shift 2
  EXTRA_ARGS="$@"

  echo ""
  echo "========================================="
  echo "Deploying $RELEASE_NAME..."
  echo "========================================="

  # If release is in failed state, uninstall first
  STATUS=$(helm status $RELEASE_NAME -n retail-app 2>/dev/null | grep STATUS | awk '{print $2}' || echo "not-found")
  if [ "$STATUS" = "failed" ]; then
    echo "Release $RELEASE_NAME is in failed state. Uninstalling first..."
    helm uninstall $RELEASE_NAME -n retail-app
    sleep 5
  fi

  helm upgrade --install $RELEASE_NAME $CHART \
    -n retail-app \
    --wait \
    --timeout 10m \
    $EXTRA_ARGS
}

# Deploy infrastructure charts
deploy_chart mysql ./mysql
deploy_chart postgresql ./postgresql
deploy_chart redis ./redis
deploy_chart dynamodb ./dynamodb
deploy_chart rabbitmq ./rabbitmq

# Deploy microservices
deploy_chart frontend \
  oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart \
  --version 1.4.0 \
  -f ./ms-values/frontend-values.yaml

deploy_chart catalog \
  oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart \
  --version 1.4.0 \
  -f ./ms-values/catalog-values.yaml

deploy_chart cart \
  oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart \
  --version 1.4.0 \
  -f ./ms-values/cart-values.yaml

deploy_chart orders \
  oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart \
  --version 1.4.0 \
  -f ./ms-values/orders-values.yaml

deploy_chart checkout \
  oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart \
  --version 1.4.0 \
  -f ./ms-values/checkout-values.yaml

echo ""
echo "========================================="
echo "Deployment Status Summary"
echo "========================================="
echo "Pods:"
kubectl get pods -n retail-app

echo ""
echo "PVCs:"
kubectl get pvc -n retail-app

echo ""
echo "Services:"
kubectl get svc -n retail-app

echo ""
echo "Helm Releases:"
helm list -n retail-app

echo ""
echo "========================================="
echo "✅ Deployment completed successfully!"
echo "========================================="