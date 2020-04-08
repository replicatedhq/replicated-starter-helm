SHELL := /bin/bash -o pipefail

app_slug := "${REPLICATED_APP}"

# Generate release notes that provide origin details.
ifeq ($(origin GITHUB_ACTIONS), undefined)
release_notes := "CLI release of $(shell git symbolic-ref HEAD) triggered by ${shell git config --global user.name}: $(shell basename $$(git remote get-url origin) .git) [SHA: $(shell git rev-parse HEAD)]"
else
release_notes := "GitHub Action release of ${GITHUB_REF} triggered by ${GITHUB_ACTOR}: [$(shell echo $${GITHUB_SHA::7})](https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA})"
endif

# If tag is set and we're using github_actions, that takes precedence and we release on the beta channel.
# Otherwise, get the branch use to build version and release on that channel
ifeq ($(GITHUB_TAG_NAME),)
ifeq ($(GITHUB_BRANCH_NAME),)
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

# Get current version for use with semver
release_type ?= patch # (supported values: patch, minor, major)
current_version := $(shell git ls-remote --tags -q | awk '{print $$2}' | grep "v[0-9][0-9]*" | sort -nr | head -n1|sed 's/refs\/tags\///g')
ifndef current_version
  current_version := 0.0.0
endif


.PHONY: deps-vendor-cli
deps-vendor-cli: upstream_version = $(shell  curl --silent --location --fail --output /dev/null --write-out %{url_effective} https://github.com/replicatedhq/replicated/releases/latest | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+$$')
deps-vendor-cli: dist = $(shell echo `uname` | tr '[:upper:]' '[:lower:]')
deps-vendor-cli: cli_version = ""
deps-vendor-cli: cli_version = $(shell [[ -x deps/replicated ]] && deps/replicated version | grep version | head -n1 | cut -d: -f2 | tr -d , | tr -d '"' | tr -d " " )

deps-vendor-cli:
	: CLI Local Version $(cli_version)
	: CLI Upstream Version $(upstream_version)
	@if [[ "$(cli_version)" == "$(upstream_version)" ]]; then \
	   echo "Latest CLI version $(upstream_version) already present"; \
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
.PHONY: release
release-kurl-installer: check-api-token check-app deps-vendor-cli
	deps/replicated installer create \
		--app $(app_slug) \
		--yaml-file kurl.yaml \
		--promote $(channel) \
		--ensure-channel


# Preserving for backwards compatibility (behavior was merged on release).
.PHONY gitsha-release:
gitsha-release: release

# Return the current version. The latest tag based on semver sort order.
.PHONY current-version:
current-version:
	@echo $(current_version)

# make next-version returns 1.0.1 if current version is 1.0 or 1.0.0
# make next-version release_type=minor returns 1.1.0 if current version is 1.0 or 1.0.0 or 1
.PHONY next-version:
next-version:
	@echo v$(shell docker run --rm alpine/semver semver -c -i $(release_type) $(current_version))

# tag and push the next semver version (resulting in CI release on "Beta" channel). Can specify release_type. Default is patch (1.0.0 -> 1.0.1).
.PHONY tag-next-version:
tag-next-version: next_tag=v$(shell docker run --rm alpine/semver semver -c -i $(release_type) $(current_version))
tag-next-version: current_branch=$(shell git rev-parse --abbrev-ref HEAD)
tag-next-version:
	git checkout master;
	git tag $(next_tag)
	git push origin $(next_tag)
	git checkout $(current_branch)
