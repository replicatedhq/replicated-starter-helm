SHELL := /bin/bash -o pipefail

app_slug := "${REPLICATED_APP}"
release_notes := "CLI release by ${shell git log -1 --pretty=format:'%ae'} on $(shell date)"

# If tag is set and we're using github_actions, that takes precedence and we release on the beta channel. 
# Otherwise, get the branch, ensure the first char is uppercase, and use to build version. 
ifeq ($(origin GITHUB_TAG_NAME),undefined)
ifeq ($(origin ${GITHUB_BRANCH_NAME}),undefined)
channel := $(shell ch=$$(git rev-parse --abbrev-ref HEAD);echo $$(tr '[:lower:]' '[:upper:]' <<< $${ch:0:1})$${ch:1})
else 
channel := $(shell ch=$$(GITHUB_BRANCH_NAME);echo $$(tr '[:lower:]' '[:upper:]' <<< $${ch:0:1})$${ch:1})
endif 
# Translate "Master" to "Unstable", if on that branch
ifeq ($(channel), Master)
channel := Unstable
endif 
version := $(channel)-$(shell git rev-parse HEAD | head -c7)$(shell git diff --no-ext-diff --quiet --exit-code || echo "-dirty")
else 
channel := "Beta"
version := ${GITHUB_TAG_NAME}
endif

.PHONY: deps-vendor-cli
deps-vendor-cli:
	@if [[ -x deps/replicated ]]; then exit 0; else \
	echo '-> Downloading Replicated CLI... '; \
	mkdir -p deps/; \
	if [[ "`uname`" == "Linux" ]]; then curl -fsSL https://github.com/replicatedhq/replicated/releases/download/v0.15.0/replicated_0.19.0_linux_amd64.tar.gz | tar xvz -C deps; exit 0; fi; \
	if [[ "`uname`" == "Darwin" ]]; then curl -fsSL https://github.com/replicatedhq/replicated/releases/download/v0.15.0/replicated_0.19.0_darwin_amd64.tar.gz | tar xvz -C deps; exit 0; fi; fi;

.PHONY: lint
lint: check-api-token check-app deps-vendor-cli
	deps/replicated release lint --app $(app_slug) --yaml-dir manifests

.PHONY: check-api-token
check-api-token:
	@if [ -z "${REPLICATED_API_TOKEN}" ]; then echo "Missing REPLICATED_API_TOKEN"; exit 1; fi

.PHONY: check-app
check-app:
	@if [ -z "$(app_slug)" ]; then echo "Missing REPLICATED_APP"; exit 1; fi

.PHONY: list-releases
list-releases: check-api-token check-app deps-vendor-cli
	deps/replicated release ls --app $(app_slug)

.PHONY: release
release: check-api-token check-app deps-vendor-cli
	@if [[ ${channel) == -x ../deps/replicated ]]; then exit 0; else \
	deps/replicated release create \
		--app $(app_slug) \
		--yaml-dir manifests \
		--promote $(channel) \
		--version $(version) \
		--release-notes $(release_notes)
