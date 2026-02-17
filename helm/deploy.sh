#!/bin/bash
set -e

echo "Authenticating with EKS cluster..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION
kubectl get nodes

echo "Logging into Public ECR..."
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

echo "Deploying MySQL..."
helm upgrade --install mysql ./mysql -n retail-app

echo "Deploying PostgreSQL..."
helm upgrade --install postgresql ./postgresql -n retail-app

echo "Deploying Redis..."
helm upgrade --install redis ./redis -n retail-app

echo "Deploying DynamoDB..."
helm upgrade --install dynamodb ./dynamodb -n retail-app

echo "Deploying RabbitMQ..."
helm upgrade --install rabbitmq ./rabbitmq -n retail-app

echo "Waiting 30s for pods to initialize..."
sleep 30

echo "Waiting for MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n retail-app --timeout=300s

echo "Waiting for PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgresql -n retail-app --timeout=300s

echo "Waiting for Redis..."
kubectl wait --for=condition=ready pod -l app=redis -n retail-app --timeout=300s

echo "Deploying Frontend..."
helm upgrade --install frontend oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart --version 1.4.0 --namespace retail-app -f ./ms-values/frontend-values.yaml --wait --timeout 10m

echo "Deploying Catalog..."
helm upgrade --install catalog oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart --version 1.4.0 --namespace retail-app -f ./ms-values/catalog-values.yaml --wait --timeout 10m

echo "Deploying Cart..."
helm upgrade --install cart oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart --version 1.4.0 --namespace retail-app -f ./ms-values/cart-values.yaml --wait --timeout 10m

echo "Deploying Orders..."
helm upgrade --install orders oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart --version 1.4.0 --namespace retail-app -f ./ms-values/orders-values.yaml --wait --timeout 10m

echo "Deploying Checkout..."
helm upgrade --install checkout oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart --version 1.4.0 --namespace retail-app -f ./ms-values/checkout-values.yaml --wait --timeout 10m

kubectl get pods -n retail-app
kubectl get svc -n retail-app
helm list -n retail-app
echo "Deployment completed successfully!"