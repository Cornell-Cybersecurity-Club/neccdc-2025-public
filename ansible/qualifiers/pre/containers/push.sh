#!/bin/bash

BUILD_ARGS='--platform=linux/amd64 --label maintainer=PlaceboPharma'

aws ecr-public get-login-password --profile neccdc-2025 --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/abcdefg

for service in etcher grapher recorder; do
  docker build ./$service/ $BUILD_ARGS -t public.ecr.aws/abcdefg/placebopharma/$service:latest
  docker push public.ecr.aws/abcdefg/placebopharma/$service:latest
done
