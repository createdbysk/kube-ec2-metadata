# Image URL to use all building/pushing image targets;
# Use your own docker registry and image name for dev/test by overridding the
# IMAGE_REPO, IMAGE_NAME and IMAGE_TAG environment variable.
IMAGE_REPO ?= docker.io/satvidh
IMAGE_NAME ?= sidecar-injector

INJECTOR_NAMESPACE ?= sidecar-injector
INJECTION_NAMESPACE ?= injection

# Github host to use for checking the source tree;
# Override this variable ue with your own value if you're working on forked repo.
GIT_HOST ?= github.com/satvidh

PWD := $(shell pwd)
BASE_DIR := $(shell basename $(PWD))

############################################################
# guard section
############################################################

guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
	fi

############################################################
# test section
############################################################

test:
	@echo "Running the tests for $(IMAGE_NAME)..."
	@go test $(TESTARGS) ./...

test-install: guard-POD_ROLE_NAME clean-test-install
	@echo "Running alpine image to test installation..."
	@kubectl run alpine --image=alpine --restart=Never \
		-n $(INJECTION_NAMESPACE) \
		--overrides="{\"apiVersion\":\"v1\",\"metadata\":{\"annotations\":{\"sidecar-injector-webhook.satvidh/inject\":\"yes\",\"iam.amazonaws.com/role\":\"arn:aws:iam::$(shell aws sts get-caller-identity | jq .Account -r):role/$(POD_ROLE_NAME)\"}}}" \
		--command -- sleep infinity
	@sleep 10; kubectl get pods -n $(INJECTION_NAMESPACE)
############################################################
# image section
############################################################

image: build-image push-image

build-image: 
	@echo "Building the docker image: $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)..."
	@cd src; docker build -t $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) .

tag-image-latest: build-image
	@echo "Tag the docker image for $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) as $(IMAGE_REPO)/$(IMAGE_NAME):latest..."
	@docker tag $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_REPO)/$(IMAGE_NAME):latest

push-image: build-image tag-image-latest
	@echo "Pushing the docker image for $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) and $(IMAGE_REPO)/$(IMAGE_NAME):latest..."
	@docker push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)
	@docker push $(IMAGE_REPO)/$(IMAGE_NAME):latest

build:
	mkdir -p build

install: clean build
	-@kubectl create ns $(INJECTOR_NAMESPACE)
	./deployment/webhook-create-signed-cert.sh \
    	--service sidecar-injector-webhook-svc \
    	--secret sidecar-injector-webhook-certs \
    	--namespace $(INJECTOR_NAMESPACE)
	cat deployment/mutatingwebhook.yaml | \
		deployment/webhook-patch-ca-bundle.sh > \
		build/mutatingwebhook-ca-bundle.yaml
	kubectl create -f deployment/configmap.yaml
	kubectl create -f deployment/deployment.yaml
	kubectl create -f deployment/service.yaml
	kubectl create -f build/mutatingwebhook-ca-bundle.yaml

injection:
	@echo "Checking aws credentials..."
	@aws sts get-caller-identity
	-@kubectl create ns $(INJECTION_NAMESPACE)
	@kubectl label namespace $(INJECTION_NAMESPACE) sidecar-injection=enabled
	@kubectl create secret generic sidecar-injector-secrets \
		-n $(INJECTION_NAMESPACE) \
		--from-literal=awsAccessKeyId=${AWS_ACCESS_KEY_ID} \
		--from-literal=awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
		--from-literal=awsSessionToken=${AWS_SESSION_TOKEN}
	@kubectl create configmap sidecar-injector-config \
		--from-literal=awsRegion=${AWS_DEFAULT_REGION} \
		-n $(INJECTION_NAMESPACE)

############################################################
# clean section
############################################################
clean-test-install:
	-@kubectl delete pod alpine -n $(INJECTION_NAMESPACE)

clean-injection:
	-@kubectl delete ns $(INJECTION_NAMESPACE)

clean-injector:
	-@kubectl delete -f build/mutatingwebhook-ca-bundle.yaml
	-@kubectl delete ns $(INJECTOR_NAMESPACE)

clean: clean-injection clean-injector
	@rm -rf build
	

.PHONY: all fmt lint check test image install injection clean

