.PHONY: watch
watch: build
	$(MAKE) -j 3 watch-vite run-server watch-build 

.PHONY: build
build:
	@dune build 

.PHONY: watch-build
watch-build:
	dune build @default --watch

.PHONY: run-server
run-server: 
	@watchexec --debounce "100ms" --no-ignore -w .processes/last_built_at.txt -r \
  -- "./scripts/start-server.sh"

.PHONY: watch-vite
watch-vite:
	./node_modules/.bin/vite --host
