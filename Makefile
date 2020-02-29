SHELL := /bin/bash -o pipefail

app_slug := "${REPLICATED_APP}"

# Generate release notes that provide origin details. 
ifeq ($(origin GITHUB_ACTIONS), undefined)
release_notes := "CLI release of $(shell git symbolic-ref HEAD) triggered by ${shell git log -1 --pretty=format:'%ae'}: $(shell basename $$(git remote get-url origin) .git) [SHA: $(shell git rev-parse HEAD)]"
else 
release_notes := "GitHub Action release of ${GITHUB_REF} triggered by ${GITHUB_ACTOR}: [$(shell echo $${GITHUB_SHA::7})](https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA})"
endif 

# If tag is set and we're using github_actions, that takes precedence and we release on the beta channel. 
# Otherwise, get the branch use to build version and release on that channel
ifeq ($(origin GITHUB_TAG_NAME),undefined)
ifeq ($(origin GITHUB_BRANCH_NAME),undefined)
channel := $(shell git rev-parse --abbrev-ref HEAD)
else 
channel := ${GITHUB_BRANCH_NAME}
endif 
# Translate "Master" to "Unstable", if on that branch
ifeq ($(channel), master)
channel := Unstable
endif 
version := $(channel)-$(shell git rev-parse HEAD | head -c7)$(shell git diff --no-ext-diff --quiet --exit-code || echo "-dirty")
else 
channel := "Beta"
version := ${GITHUB_TAG_NAME}
endif

.PHONY: deps-vendor-cli
deps-vendor-cli: dist = $(shell echo `uname` | tr '[:upper:]' '[:lower:]')
deps-vendor-cli: cli_version = ""
deps-vendor-cli: cli_version = $(shell [[ -x deps/replicated ]] && deps/replicated version | grep version | head -n1 | cut -d: -f2 | tr -d , )

deps-vendor-cli: 
	@if [[ -n "$(cli_version)" ]]; then \
	  echo "CLI version $(cli_version) already downloaded, to download a newer version, run 'make upgrade-cli'"; \
	  exit 0; \
	else \
	  echo '-> Downloading Replicated CLI to ./deps '; \
	  mkdir -p deps/; \
	  curl -s https://api.github.com/repos/replicatedhq/replicated/releases/latest \
	  | grep "browser_download_url.*$(dist)_amd64.tar.gz" \
	  | cut -d : -f 2,3 \
	  | tr -d \" \
	  | wget -O- -qi - \
	  | tar xvz -C deps; \
	fi

.PHONY: upgrade-cli
upgrade-cli:
	rm -rf deps
	@$(MAKE) deps-vendor-cli

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
release: check-api-token check-app deps-vendor-cli lint
	deps/replicated release create \
		--app $(app_slug) \
		--yaml-dir manifests \
		--promote $(channel) \
		--version $(version) \
		--release-notes $(release_notes) \
		--ensure-channel


# Preserving for backwards compatibility (behavior was merged on release). 
gitsha-release: release
