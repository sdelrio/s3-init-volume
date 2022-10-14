
.PHONY: all build-images build-test-images test-images push-images update-version

IMAGE_NAME ?= sdelrio/s3-init-volume
IMAGE_TAG ?= $(shell git rev-parse --short HEAD)-$(shell cat awscli_version)-$(shell cat endpoint_version)
IMAGE_TEST_TAG ?= test
IMAGE_PREFIX ?= docker.pkg.github.com
GPR_TEST_TAG ?= build-cache-tests-no-buildkit
GPR_TAG ?= build-cache-no-buildkit

VERSION ?= master
FILE_VERSION = $(shell cat VERSION)
DOCKERFILES ?= $(shell find . -maxdepth 1 -name 'Dockerfile*')

AWS_CLI_ENDPOINT_VERSION ?= $(shell cat endpoint_version)
AWS_CLI_VERSION ?= $(shell cat awscli_version)

.DEFAULT: help
help:	## Show this help menu.
	@echo "Usage: make [TARGET ...]"
	@echo ""
	@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

build-images:	## Build images
build-images:
	@for DOCKERFILE in $(DOCKERFILES);do \
        export TAG_SUFFIX=`echo $${DOCKERFILE} | sed 's/\.\/Dockerfile//' | tr '.' '-'`; \
		echo "--> Building $(IMAGE_NAME):$(IMAGE_TAG)$${TAG_SUFFIX}"; \
		docker build --progress=plain -f $$DOCKERFILE \
			--build-arg AWS_CLI_ENDPOINT_VERSION=$(AWS_CLI_ENDPOINT_VERSION) \
			--build-arg AWS_CLI_VERSION=$(AWS_CLI_VERSION) \
			-t $(IMAGE_NAME):$(IMAGE_TAG)$${TAG_SUFFIX}\
			. || exit -1 ;\
	done; \

build-images-gpr:	## Build images with Github Package Registry
build-images-gpr:
	@for DOCKERFILE in $(DOCKERFILES);do \
        export TAG_SUFFIX=`echo $${DOCKERFILE} | sed 's/\.\/Dockerfile//' | tr '.' '-'`; \
		echo "--> Pulling cache image $(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX}"; \
		docker pull $(IMAGE_PREFIX)/$(GITHUB_REPOSITORY)/$(GPR_TEST_TAG) || true ; \
		echo "--> Building $(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX}"; \
		docker build \
			-t $(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} \
			--build-arg AWS_CLI_ENDPOINT_VERSION=$(AWS_CLI_ENDPOINT_VERSION) \
			--build-arg AWS_CLI_VERSION=$(AWS_CLI_VERSION) \
			--cache-from=$(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} \
			--progress=plain -f $$DOCKERFILE \
			. || exit -1 ;\
		echo "----> Builder finished" ; \
		docker push $(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} || true ; \
		echo "----> Cache push finished" ; \
		docker build \
			-t $(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} \
			--cache-from=$(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} \
			--progress=plain -f $$DOCKERFILE \
			. || exit -1 ;\
		echo "----> Run Build finished" ; \
		docker tag \
			$(IMAGE_PREFIX)/$$GITHUB_REPOSITORY/$(GPR_TAG)$${TAG_SUFFIX} \
			$(IMAGE_NAME):$(IMAGE_TAG)$${TAG_SUFFIX} || exit 2 \
		echo "----> Dockerhub tag image finished" ; \
	done; \


publish-images:	## Publish docker images
publish-images: build-images
	@for DOCKERFILE in $(DOCKERFILES);do \
        export TAG_SUFFIX=`echo $${DOCKERFILE} | sed 's/\.\/Dockerfile//' | tr '.' '-'`; \
		echo "--> Publishing $(IMAGE_NAME):$(IMAGE_TAG)$${TAG_SUFFIX}"; \
		docker push $(IMAGE_NAME):$(IMAGE_TAG)$${TAG_SUFFIX} ; \
	done; \

publish-images-gh:	## Publish docker images Git Hub packages
publish-images-gh: build-images
	@for DOCKERFILE in $(DOCKERFILES);do \
        export TAG_SUFFIX=`echo $${DOCKERFILE} | sed 's/\.\/Dockerfile//' | tr '.' '-'`; \
		echo "--> Publishing $(IMAGE_PREFIX)/$(IMAGE_NAME)/$(IMAGE_TAG)$${TAG_SUFFIX}:$${GITHUB_RUN_NUMBER}"; \
		docker tag \
			$(IMAGE_NAME):$(IMAGE_TEST_TAG)$${TAG_SUFFIX} \
			$(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_TAG)/$${TAG_SUFFIX}:$${GITHUB_RUN_NUMBER} ; \
		docker push $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_TAG)/$${TAG_SUFFIX}:$${GITHUB_RUN_NUMBER} ; \
	done; \

update-version: ## Update version from VERSION file in all Dockerfiles
update-version:
	@for DOCKERFILE in $(DOCKERFILES);do \
		curl -s https://pypi.org/pypi/awscli/json | jq -r '.releases | keys| .[]' | sort -V |tail -n 1 > awscli_version_latest ; \
		curl -s https://pypi.org/pypi/awscli-plugin-endpoint/json | jq -r '.releases | keys| .[]' | sort -V |tail -n 1 > endpoint_version_latest ; \
	done; \
	if [ $(shell diff -q awscli_version_latest awscli_version > /dev/null; echo -n $$?) -ne 0 ]; then \
		echo Updating awscli to version "$(shell cat awscli_version_latest)"; \
		cp -f awscli_version_latest awscli_version ; \
	fi; \
	if [ $(shell diff -q endpoint_version_latest endpoint_version >/dev/null; echo -n $$?) -ne 0 ]; then \
		echo Updating endpoint plugin to version "$(shell cat endpoint_version_latest)"; \
		cp -f endpoint_version_latest endpoint_version ;\
	fi; \
	rm -f awscli_version_latest ; \
	rm -f endpoint_version_latest ; \
	echo Finished checking update version



