DKN_ADDR ?= localhost
DKN_PORT ?= 50052

.PHONY: deps
deps:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

.PHONY: build
build:
	protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative service.proto

.PHONY: debug
debug:
	evans --path . --proto service.proto --host ${DKN_ADDR} --port ${DKN_PORT}

.PHONY: bump-version-patch
bump-version-patch:
	@printf "%s.%s" \
		$(shell git tag --sort=committerdate | grep -E '^v[0-9]' | tail -1 | cut -d "." -f 1-2) \
		$(shell git tag --sort=committerdate | grep -E '^v[0-9]' | tail -1 | cut -d "." -f 3 | xargs expr 1 +) \
		> .new_version

	git tag $(shell cat .new_version)
	git push origin $(shell cat .new_version)
	rm .new_version

	