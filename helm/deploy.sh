#!/bin/bash

set -e

echo "========================================="
echo "Starting deployment to retail-app namespace"
echo "========================================="

echo "Authenticating with EKS cluster..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

echo "Testing cluster connection..."
kubectl get nodes

echo "Logging into Public ECR..."
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

echo ""
echo "========================================="
echo "Deploying Infrastructure..."
echo "========================================="

helm upgrade --install mysql ./mysql -n retail-app
echo "✅ MySQL submitted"

helm upgrade --install postgresql ./postgresql -n retail-app
echo "✅ PostgreSQL submitted"

helm upgrade --install redis ./redis -n retail-app
echo "✅ Redis submitted"

helm upgrade --install dynamodb ./dynamodb -n retail-app
echo "✅ DynamoDB submitted"

helm upgrade --install rabbitmq ./rabbitmq -n retail-app
echo "✅ RabbitMQ submitted"

echo ""
echo "========================================="
echo "Waiting for infrastructure to be Ready..."
echo "========================================="
sleep 30

kubectl wait --for=condition=ready pod -l app=mysql -n retail-app --timeout=300s
echo "✅ MySQL Ready"

kubectl wait --for=condition=ready pod -l app=postgresql -n retail-app --timeout=300s
echo "✅ PostgreSQL Ready"

kubectl wait --for=condition=ready pod -l app=redis -n retail-app --timeout=300s
echo "✅ Redis Ready"

echo ""
echo "========================================="
echo "Deploying Microservices..."
echo "========================================="

helm upgrade --install frontend \
  oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart \
  --version 1.4.0 \
  --namespace retail-app \
  -f ./ms-values/frontend-values.yaml \
  --wait --timeout 10m
echo "✅ Frontend deployed"

helm upgrade --install catalog \
  oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart \
  --version 1.4.0 \
  --namespace retail-app \
  -f ./ms-values/catalog-values.yaml \
  --wait --timeout 10m
echo "✅ Catalog deployed"

helm upgrade --install cart \
  oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart \
  --version 1.4.0 \
  --namespace retail-app \
  -f ./ms-values/cart-values.yaml \
  --wait --timeout 10m
echo "✅ Cart deployed"

helm upgrade --install orders \
  oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart \
  --version 1.4.0 \
  --namespace retail-app \
  -f ./ms-values/orders-values.yaml \
  --wait --timeout 10m
echo "✅ Orders deployed"

helm upgrade --install checkout \
  oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart \
  --version 1.4.0 \
  --namespace retail-app \
  -f ./ms-values/checkout-values.yaml \
  --wait --timeout 10m
echo "✅ Checkout deployed"

echo ""
echo "========================================="
echo "Deployment Status Summary"
echo "========================================="
kubectl get pods -n retail-app
echo ""
kubectl get pvc -n retail-app
echo ""
kubectl get svc -n retail-app
echo ""
helm list -n retail-app

echo ""
echo "========================================="
echo "✅ Deployment completed successfully!"
echo "========================================="