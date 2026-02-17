#!/bin/bash

set -e  # Exit immediately if any command fails

echo "========================================="
echo "Starting deployment to retail-app namespace"
echo "========================================="

echo "Logging into Public ECR..."
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

echo ""
echo "========================================="
echo "Deploying MySQL..."
echo "========================================="
helm upgrade --install mysql ./mysql -n retail-app --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying PostgreSQL..."
echo "========================================="
helm upgrade --install postgresql ./postgresql -n retail-app --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Redis..."
echo "========================================="
helm upgrade --install redis ./redis -n retail-app --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying DynamoDB..."
echo "========================================="
helm upgrade --install dynamodb ./dynamodb -n retail-app --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying RabbitMQ..."
echo "========================================="
helm upgrade --install rabbitmq ./rabbitmq -n retail-app --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Frontend Microservice..."
echo "========================================="
helm upgrade --install frontend oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart --version 1.4.0 --namespace retail-app -f ./ms-values/frontend-values.yaml --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Catalog Microservice..."
echo "========================================="
helm upgrade --install catalog oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart --version 1.4.0 --namespace retail-app -f ./ms-values/catalog-values.yaml --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Cart Microservice..."
echo "========================================="
helm upgrade --install cart oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart --version 1.4.0 --namespace retail-app -f ./ms-values/cart-values.yaml --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Orders Microservice..."
echo "========================================="
helm upgrade --install orders oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart --version 1.4.0 --namespace retail-app -f ./ms-values/orders-values.yaml --wait --timeout 5m

echo ""
echo "========================================="
echo "Deploying Checkout Microservice..."
echo "========================================="
helm upgrade --install checkout oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart --version 1.4.0 --namespace retail-app -f ./ms-values/checkout-values.yaml --wait --timeout 5m

echo ""
echo "========================================="
echo "Waiting for all pods to stabilize..."
echo "========================================="
sleep 60

echo ""
echo "========================================="
echo "Deployment Status Summary"
echo "========================================="

echo ""
echo "Pods Status:"
kubectl get pods -n retail-app

echo ""
echo "========================================="
echo "Persistent Volume Claims:"
kubectl get pvc -n retail-app

echo ""
echo "========================================="
echo "Services:"
kubectl get svc -n retail-app

echo ""
echo "========================================="
echo "Helm Releases:"
helm list -n retail-app

echo ""
echo "========================================="
echo "✅ Deployment completed successfully!"
echo "========================================="