PKG=github.com/andrewzeneski/eeasyjson
GOPATH:=$(PWD)/.root:$(GOPATH)
export GOPATH

all: test

.root/src/$(PKG): 	
	mkdir -p $@
	for i in $$PWD/* ; do ln -s $$i $@/`basename $$i` ; done 

root: .root/src/$(PKG)

clean:
	rm -rf .root

build:
	go build -i -o .root/bin/eeasyjson $(PKG)/eeasyjson

generate: root build
	.root/bin/eeasyjson -stubs \
		.root/src/$(PKG)/tests/snake.go \
		.root/src/$(PKG)/tests/data.go \
		.root/src/$(PKG)/tests/omitempty.go \
		.root/src/$(PKG)/tests/nothing.go \
		.root/src/$(PKG)/tests/named_type.go

	.root/bin/eeasyjson -all .root/src/$(PKG)/tests/data.go
	.root/bin/eeasyjson -all .root/src/$(PKG)/tests/nothing.go
	.root/bin/eeasyjson -all .root/src/$(PKG)/tests/errors.go
	.root/bin/eeasyjson -snake_case .root/src/$(PKG)/tests/snake.go
	.root/bin/eeasyjson -omit_empty .root/src/$(PKG)/tests/omitempty.go
	.root/bin/eeasyjson -build_tags=use_easyjson .root/src/$(PKG)/benchmark/data.go
	.root/bin/eeasyjson .root/src/$(PKG)/tests/nested_easy.go
	.root/bin/eeasyjson .root/src/$(PKG)/tests/named_type.go

test: generate root
	go test \
		$(PKG)/tests \
		$(PKG)/jlexer \
		$(PKG)/gen \
		$(PKG)/buffer
	go test -benchmem -tags use_easyjson -bench . $(PKG)/benchmark
	golint -set_exit_status .root/src/$(PKG)/tests/*_easyjson.go

bench-other: generate root
	@go test -benchmem -bench . $(PKG)/benchmark
	@go test -benchmem -tags use_ffjson -bench . $(PKG)/benchmark
	@go test -benchmem -tags use_codec -bench . $(PKG)/benchmark

bench-python:
	benchmark/ujson.sh


.PHONY: root clean generate test build
