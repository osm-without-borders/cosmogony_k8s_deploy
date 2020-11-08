REGISTRY_URL=my-local-registry.url
REGISTRY_NAMESPACE=default

.DEFAULT_GOAL := help

init: ## 
				git submodule add -b master -f https://github.com/osm-without-borders/cosmogony_explorer ./cosmogony_explorer
				git submodule update

clean: ## 
				git rm -f cosmogony_explorer
				rm -rf ../.git/modules/cosmogony_explorer

build_importer: ## 
				cd cosmogony_explorer && git reset origin/master --hard
				git submodule update --remote
				docker build -t $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_importer -f cosmogony_explorer/importer/Dockerfile ./cosmogony_explorer/importer
				docker push $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_importer

build_trex: ## 
				sed -i 's/cosmogony@postgres\/cosmogony/cosmogony@postgres-postgresql.default\/cosmogony/' cosmogony_explorer/tiles/config.toml.template
				docker build -t $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_tiles -f cosmogony_explorer/tiles/Dockerfile ./cosmogony_explorer/tiles
				docker push $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_tiles

build_api: ## 
				docker build -t $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_api -f cosmogony_explorer/api/Dockerfile ./cosmogony_explorer/api
				docker push $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_api

build_web: ## 
				sed -i 's/\/api:8000\//\/cosmogony-api:8000\//' cosmogony_explorer/explorer/nginx.vh.default.conf
				sed -i 's/\/tiles:6767\//\/cosmogony-trex:6767\//' cosmogony_explorer/explorer/nginx.vh.default.conf
				sed -i 's/maps.tilehosting.com\/styles\/positron\/style.json?key=dcCQFarAif6ie2xrgCEF/api.maptiler.com\/maps\/positron\/style.json?key=cgwcxeEQWSNDybCr1tZq/' cosmogony_explorer/explorer/src/map.js
				docker build -t $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_web -f cosmogony_explorer/explorer/Dockerfile ./cosmogony_explorer/explorer
				docker push $(REGISTRY_URL)/$(REGISTRY_NAMESPACE)/cosmogony_explorer_web

help: ## Print this help message
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'	

