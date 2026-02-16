l#! /bin/bash

aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

helm upgrade --install mysql ./mysql -n retail-app

echo "================================"

helm upgrade --install postgresql ./postgresql -n retail-app

echo "================================"

helm upgrade --install redis ./redis -n retail-app

echo "================================"

helm upgrade --install dynamodb ./dynamodb -n retail-app

echo "================================"

helm upgrade --install rabbitmq ./rabbitmq -n retail-app

echo "================================"

helm upgrade --install frontend   oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart   --version 1.4.0   --namespace retail-app -f ./ms-values/frontend-values.yaml

echo "================================"

helm upgrade --install catalog   oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/catalog-values.yaml

echo "================================"

helm upgrade --install cart  oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/cart-values.yaml

echo "================================"

helm upgrade --install orders   oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/orders-values.yaml

echo "================================"

helm upgrade --install checkout  oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart   --version 1.4.0   --namespace retail-app -f ./ms-values/checkout-values.yaml

echo "================================"

sleep 60

kubectl get pods -n retail-app

echo "================================"

kubectl get pvc -n retail-app

echo "================================"

kubectl get svc -n retail-app
