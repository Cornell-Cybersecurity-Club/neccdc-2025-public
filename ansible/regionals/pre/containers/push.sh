#!/bin/bash

export VERSION_TAG="v1.2.0"

build_n_push () {
  docker build ./$2/ $BUILD_ARGS -t public.ecr.aws/abcdefg/placebo-pharma/$1:latest
  docker tag public.ecr.aws/abcdefg/placebo-pharma/$1:latest public.ecr.aws/abcdefg/placebo-pharma/$1:$VERSION_TAG
  docker push public.ecr.aws/abcdefg/placebo-pharma/$1:latest
  docker push public.ecr.aws/abcdefg/placebo-pharma/$1:$VERSION_TAG
}


BUILD_ARGS='--platform=linux/amd64 --label maintainer=PlaceboPharma'

aws ecr-public get-login-password --profile neccdc-2025 --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/abcdefg


build_n_push "website" "web"
build_n_push "etcher" "etcher"
build_n_push "grapher-http" "grapher/http"
build_n_push "grapher-renderer" "grapher/renderer"
build_n_push "processor" "processor"
build_n_push "recorder" "recorder"
