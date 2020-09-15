SHELL := /bin/bash -o pipefail
app_slug := "${REPLICATED_APP}"

.PHONY: deps-vendor-cli
deps-vendor-cli: upstream_version = $(shell  curl --silent --location --fail --output /dev/null --write-out %{url_effective} https://github.com/replicatedhq/replicated/releases/latest | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+$$')
deps-vendor-cli: dist = $(shell echo `uname` | tr '[:upper:]' '[:lower:]')
deps-vendor-cli: cli_version = ""
deps-vendor-cli: cli_version = $(shell [[ -x deps/replicated ]] && deps/replicated version | grep version | head -n1 | cut -d: -f2 | tr -d , | tr -d '"' | tr -d " " )
deps-vendor-cli: cli_url = $(shell curl -s https://api.github.com/repos/replicatedhq/replicated/releases/latest  | grep "browser_download_url.*$(dist)_amd64.tar.gz" | cut -d : -f 2,3 | tr -d \")

deps-vendor-cli:
	: CLI Local Version $(cli_version)
	: CLI Upstream Version $(upstream_version)
	@if [[ "$(cli_version)" == "$(upstream_version)" ]]; then \
	   echo "Latest CLI version $(upstream_version) already present"; \
	 else \
	   echo '-> Downloading Replicated CLI to ./deps '; \
	   mkdir -p deps/; \
	   curl -fsSL $(cli_url) | tar xvz -C deps; \
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
		--auto -y

.PHONY: release-kurl-installer
release-kurl-installer: check-api-token check-app deps-vendor-cli
	deps/replicated installer create \
		--app $(app_slug) \
		--auto -y
