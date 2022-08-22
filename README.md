# Protocol Buffers + Docker

![](https://github.com/ionos-cloud/protobuf-docker/workflows/Docker%20Image/badge.svg)

> This is a fork of the awesome project [`rvolosatovs/docker-protobuf`](https://github.com/rvolosatovs/docker-protobuf)

An all-inclusive `protoc` Docker image.
It started out as https://github.com/znly/docker-protobuf fork, but grew into a stand-alone project.

## What's included

- [ckaznocha/protoc-gen-lint](https://github.com/ckaznocha/protoc-gen-lint)
- [danielvladco/go-proto-gql](https://github.com/danielvladco/go-proto-gql)
- [envoyproxy/protoc-gen-validate](https://github.com/envoyproxy/protoc-gen-validate)
- [mwitkow/go-proto-validators](https://github.com/mwitkow/go-proto-validators)
- [gogo/protobuf](https://github.com/gogo/protobuf)
- [golang/protobuf](https://github.com/protocolbuffers/protobuf-go)
- [google/protobuf](https://github.com/google/protobuf)
- [grpc-ecosystem/grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway)
- [grpc/grpc](https://github.com/grpc/grpc)
- [grpc/grpc-go](https://github.com/grpc/grpc-go)
- [grpc/grpc-java](https://github.com/grpc/grpc-java) (not on `arm64`)
- [grpc/grpc-swift](https://github.com/grpc/grpc-swift) (not on `arm64`, see https://github.com/rvolosatovs/docker-protobuf/issues/77 for potential issues)
- [grpc/grpc-web](https://github.com/grpc/grpc-web)
- [protobuf-c/protobuf-c](https://github.com/protobuf-c/protobuf-c)
- [pseudomuto/protoc-gen-doc](https://github.com/pseudomuto/protoc-gen-doc)
- [stepancheg/grpc-rust](https://github.com/stepancheg/grpc-rust)
- [stepancheg/rust-protobuf](https://github.com/stepancheg/rust-protobuf)
- [chrusty/protoc-gen-jsonschema](https://github.com/chrusty/protoc-gen-jsonschema)
- [moul/protoc-gen-gotemplate](https://github.com/moul/protoc-gen-gotemplate)

## Supported languages

- C
- C#
- C++
- Go
- Java / JavaNano (Android)
- JavaScript
- Objective-C
- PHP
- Python
- Ruby
- Rust
- Swift

## Usage

```
$ docker run --rm -v<some-path>:<some-path> -w<some-path> rvolosatovs/protoc [OPTION] PROTO_FILES
```

For help try:

```
$ docker run --rm rvolosatovs/protoc --help
```
