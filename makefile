MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.DEFAULT_GOAL := help
.ONESHELL:



#RELEASE_VERSION := 4.0-patch
#RELEASE_TAG := test-$(RELEASE_VERSION)

AWS_DEFAULT_REGION ?= eu-west-2
ECR_REPOSITORY ?= "ACCOUNT_NAME-bakery"
ECR_REGISTRY ?= "ACCOUNT_NUMBER.dkr.ecr.eu-west-2.amazonaws.com"
IMAGE_TAG ?= 0.0.0
DOCKER_USERNAME := AWS
PROJECT_NAME := "ACCOUNT_NAME-bakery"
IMAGE_NAME := python3.10 nginx1.22



.PHONY: help
help:    ## Show this help
	@grep '.*:.*##' Makefile | grep -v grep  | sort | sed 's/:.* ##/:/g' | column -t -s:

.PHONY: tag
tag:   ## Automatic Tagging of Releases
	rm -rf semantic-image-tagging
	@echo "-------------------------------------------"
	@echo "Running automatic tagging of releases..."
	@echo "-------------------------------------------"
	git clone git@github.com:ACCOUNT_NAME/semantic-image-tagging.git
	bash ./semantic-image-tagging/git-tag/git_update.sh

.PHONY: lint
lint: ## Dockerfile lint
	@echo "Running Linting docker container images "${IMAGE_NAME}""
	for i in ${IMAGE_NAME} ; do \
		docker run --rm -i hadolint/hadolint < ./docker/images/$${i}/Dockerfile ;\
	done

.PHONY: build
build: ## Build and Tag the container image
	@echo "Building and tagging container image..."
	for i in ${IMAGE_NAME} ; do \
		docker build -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${PROJECT_NAME}-$${i}-${IMAGE_TAG} ./docker/images/$${i}/; \
	done

.PHONY: image-scan
image-scan:      ## Run Trivy vulnerability scanner
	@echo "-----------------------------------------"
	@echo "Running trivy vulnerability scanner..."
	@echo "-----------------------------------------"
	for i in ${IMAGE_NAME} ; do \
		docker run --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-e ECR_REGISTRY=${ECR_REGISTRY} \
			-e ECR_REPOSITORY=${ECR_REPOSITORY} \
			-e IMAGE_TAG=${IMAGE_TAG} \
			-e PROJECT_NAME=${PROJECT_NAME} \
			public.ecr.aws/aquasecurity/trivy:canary image ${ECR_REGISTRY}/${ECR_REPOSITORY}:${PROJECT_NAME}-$${i}-${IMAGE_TAG} -s "HIGH,CRITICAL" ; \
	done

# run locally only
.PHONY: login-ecr
login-ecr:   ## Log in to AWS ECR to push image locally only
	@echo "------------------------------------"
	@echo "Logging in to AWS ECR registry..."
	@echo "------------------------------------"
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
	docker login --username ${DOCKER_USERNAME} --password-stdin ${ECR_REGISTRY}

.PHONY: push
push: ## Push image to AWS ECR
	@echo "Pushing image to AWS ECR registry..."
	for i in ${IMAGE_NAME} ; do \
		docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${PROJECT_NAME}-$${i}-${IMAGE_TAG}; \
	done



# .PHONY: cleanup
# cleanup:   ## Clean up after push
# 	docker rmi ${ECR_REGISTRY}/${ECR_REPOSITORY}:${PROJECT_NAME}-${IMAGE_NAME}-${IMAGE_TAG}
# 	docker image prune $(shell docker ps -a -q)
