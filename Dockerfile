ARG ALPINE_VERSION
ARG GO_VERSION


FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx


FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine${ALPINE_VERSION} as go_host
COPY --from=xx / /
WORKDIR /
RUN mkdir -p /out
RUN apk add --no-cache \
        build-base \
        curl


FROM --platform=$BUILDPLATFORM go_host as grpc_gateway
RUN mkdir -p ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway
ARG GRPC_GATEWAY_VERSION
RUN curl -sSL https://api.github.com/repos/grpc-ecosystem/grpc-gateway/tarball/v${GRPC_GATEWAY_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway
WORKDIR ${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /grpc-gateway-out/protoc-gen-grpc-gateway ./protoc-gen-grpc-gateway
RUN go build -ldflags '-w -s' -o /grpc-gateway-out/protoc-gen-openapiv2 ./protoc-gen-openapiv2
RUN install -D /grpc-gateway-out/protoc-gen-grpc-gateway /out/usr/bin/protoc-gen-grpc-gateway
RUN install -D /grpc-gateway-out/protoc-gen-openapiv2 /out/usr/bin/protoc-gen-openapiv2
RUN mkdir -p /out/usr/include/protoc-gen-openapiv2/options
RUN install -D $(find ./protoc-gen-openapiv2/options -name '*.proto') -t /out/usr/include/protoc-gen-openapiv2/options
RUN xx-verify /out/usr/bin/protoc-gen-grpc-gateway
RUN xx-verify /out/usr/bin/protoc-gen-openapiv2


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_doc
RUN mkdir -p ${GOPATH}/src/github.com/pseudomuto/protoc-gen-doc
ARG PROTOC_GEN_DOC_VERSION
RUN curl -sSL https://api.github.com/repos/pseudomuto/protoc-gen-doc/tarball/v${PROTOC_GEN_DOC_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/pseudomuto/protoc-gen-doc
WORKDIR ${GOPATH}/src/github.com/pseudomuto/protoc-gen-doc
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /protoc-gen-doc-out/protoc-gen-doc ./cmd/protoc-gen-doc
RUN install -D /protoc-gen-doc-out/protoc-gen-doc /out/usr/bin/protoc-gen-doc
RUN xx-verify /out/usr/bin/protoc-gen-doc


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_go_grpc
RUN mkdir -p ${GOPATH}/src/github.com/grpc/grpc-go
ARG PROTOC_GEN_GO_GRPC_VERSION
RUN curl -sSL https://api.github.com/repos/grpc/grpc-go/tarball/v${PROTOC_GEN_GO_GRPC_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/grpc/grpc-go
WORKDIR ${GOPATH}/src/github.com/grpc/grpc-go/cmd/protoc-gen-go-grpc
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /golang-protobuf-out/protoc-gen-go-grpc .
RUN install -D /golang-protobuf-out/protoc-gen-go-grpc /out/usr/bin/protoc-gen-go-grpc
RUN xx-verify /out/usr/bin/protoc-gen-go-grpc


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_go
RUN mkdir -p ${GOPATH}/src/google.golang.org/protobuf
ARG PROTOC_GEN_GO_VERSION
RUN curl -sSL https://api.github.com/repos/protocolbuffers/protobuf-go/tarball/v${PROTOC_GEN_GO_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/google.golang.org/protobuf
WORKDIR ${GOPATH}/src/google.golang.org/protobuf
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /golang-protobuf-out/protoc-gen-go ./cmd/protoc-gen-go
RUN install -D /golang-protobuf-out/protoc-gen-go /out/usr/bin/protoc-gen-go
RUN xx-verify /out/usr/bin/protoc-gen-go

FROM --platform=$BUILDPLATFORM go_host as protoc_gen_gotemplate
RUN mkdir -p ${GOPATH}/src/github.com/moul/protoc-gen-gotemplate
ARG PROTOC_GEN_GOTEMPLATE_VERSION
RUN curl -sSL https://api.github.com/repos/moul/protoc-gen-gotemplate/tarball/v${PROTOC_GEN_GOTEMPLATE_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/moul/protoc-gen-gotemplate
WORKDIR ${GOPATH}/src/github.com/moul/protoc-gen-gotemplate
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /protoc-gen-gotemplate-out/protoc-gen-gotemplate .
RUN install -D /protoc-gen-gotemplate-out/protoc-gen-gotemplate /out/usr/bin/protoc-gen-gotemplate
RUN xx-verify /out/usr/bin/protoc-gen-gotemplate


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_govalidators
RUN mkdir -p ${GOPATH}/src/github.com/mwitkow/go-proto-validators
ARG PROTOC_GEN_GOVALIDATORS_VERSION
RUN curl -sSL https://api.github.com/repos/mwitkow/go-proto-validators/tarball/v${PROTOC_GEN_GOVALIDATORS_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/mwitkow/go-proto-validators
WORKDIR ${GOPATH}/src/github.com/mwitkow/go-proto-validators
RUN mkdir /go-proto-validators-out
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /go-proto-validators-out ./...
RUN install -D /go-proto-validators-out/protoc-gen-govalidators /out/usr/bin/protoc-gen-govalidators
RUN install -D ./validator.proto /out/usr/include/github.com/mwitkow/go-proto-validators/validator.proto
RUN xx-verify /out/usr/bin/protoc-gen-govalidators


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_gql
RUN mkdir -p ${GOPATH}/src/github.com/danielvladco/go-proto-gql
ARG PROTOC_GEN_GQL_VERSION
RUN curl -sSL https://api.github.com/repos/danielvladco/go-proto-gql/tarball/v${PROTOC_GEN_GQL_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/danielvladco/go-proto-gql
WORKDIR ${GOPATH}/src/github.com/danielvladco/go-proto-gql
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /go-proto-gql-out/protoc-gen-gql ./protoc-gen-gql
RUN go build -ldflags '-w -s' -o /go-proto-gql-out/protoc-gen-gogql ./protoc-gen-gogql
RUN install -D /go-proto-gql-out/protoc-gen-gql /out/usr/bin/protoc-gen-gql
RUN install -D /go-proto-gql-out/protoc-gen-gogql /out/usr/bin/protoc-gen-gogql
RUN xx-verify /out/usr/bin/protoc-gen-gql
RUN xx-verify /out/usr/bin/protoc-gen-gogql


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_validate
ARG PROTOC_GEN_VALIDATE_VERSION
RUN mkdir -p ${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate
RUN curl -sSL https://api.github.com/repos/envoyproxy/protoc-gen-validate/tarball/v${PROTOC_GEN_VALIDATE_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate
WORKDIR ${GOPATH}/src/github.com/envoyproxy/protoc-gen-validate
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /protoc-gen-validate-out/protoc-gen-validate .
RUN install -D /protoc-gen-validate-out/protoc-gen-validate /out/usr/bin/protoc-gen-validate
RUN install -D ./validate/validate.proto /out/usr/include/github.com/envoyproxy/protoc-gen-validate/validate/validate.proto
RUN xx-verify /out/usr/bin/protoc-gen-validate


FROM --platform=$BUILDPLATFORM go_host as protoc_gen_jsonschema
RUN mkdir -p ${GOPATH}/src/github.com/chrusty/protoc-gen-jsonschema
ARG PROTOC_GEN_JSONSCHEMA_VERSION
RUN curl -sSL https://api.github.com/repos/chrusty/protoc-gen-jsonschema/tarball/${PROTOC_GEN_JSONSCHEMA_VERSION} | tar xz --strip 1 -C ${GOPATH}/src/github.com/chrusty/protoc-gen-jsonschema
WORKDIR ${GOPATH}/src/github.com/chrusty/protoc-gen-jsonschema
RUN go mod download
ARG TARGETPLATFORM
RUN xx-go --wrap
RUN go build -ldflags '-w -s' -o /protoc-gen-jsonschema/protoc-gen-jsonschema ./cmd/protoc-gen-jsonschema
RUN install -D /protoc-gen-jsonschema/protoc-gen-jsonschema /out/usr/bin/protoc-gen-jsonschema
RUN install -D ./options.proto /out/usr/include/github.com/chrusty/protoc-gen-jsonschema/options.proto
RUN xx-verify /out/usr/bin/protoc-gen-jsonschema


FROM alpine:${ALPINE_VERSION} as grpc_web
RUN apk add --no-cache \
        build-base \
        curl \
        protobuf-dev
RUN mkdir -p /grpc-web
ARG GRPC_WEB_VERSION
RUN curl -sSL https://api.github.com/repos/grpc/grpc-web/tarball/${GRPC_WEB_VERSION} | tar xz --strip 1 -C /grpc-web
WORKDIR /grpc-web
RUN make -j$(nproc) install-plugin
RUN install -Ds /usr/local/bin/protoc-gen-grpc-web /out/usr/bin/protoc-gen-grpc-web

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} as alpine_host
COPY --from=xx / /
WORKDIR /
RUN mkdir -p /out
RUN apk add --no-cache \
        curl \
        unzip


FROM --platform=$BUILDPLATFORM alpine_host as googleapis
RUN mkdir -p /googleapis
ARG GOOGLE_API_VERSION
RUN curl -sSL https://api.github.com/repos/googleapis/googleapis/tarball/${GOOGLE_API_VERSION} | tar xz --strip 1 -C /googleapis
WORKDIR /googleapis
RUN install -D ./google/api/annotations.proto /out/usr/include/google/api/annotations.proto
RUN install -D ./google/api/field_behavior.proto /out/usr/include/google/api/field_behavior.proto
RUN install -D ./google/api/http.proto /out/usr/include/google/api/http.proto
RUN install -D ./google/api/httpbody.proto /out/usr/include/google/api/httpbody.proto
RUN install -D ./google/api/label.proto /out/usr/include/google/api/label.proto
RUN install -D ./google/type/timeofday.proto /out/usr/include/google/type/timeofday.proto
RUN install -D ./google/type/latlng.proto /out/usr/include/google/type/latlng.proto
RUN install -D ./google/type/money.proto /out/usr/include/google/type/money.proto
RUN install -D ./google/type/postal_address.proto /out/usr/include/google/type/postal_address.proto
RUN install -D ./google/type/expr.proto /out/usr/include/google/type/expr.proto
RUN install -D ./google/type/datetime.proto /out/usr/include/google/type/datetime.proto
RUN install -D ./google/type/dayofweek.proto /out/usr/include/google/type/dayofweek.proto

FROM --platform=$BUILDPLATFORM alpine_host as protoc_gen_lint
RUN mkdir -p /protoc-gen-lint-out
ARG TARGETOS TARGETARCH PROTOC_GEN_LINT_VERSION
RUN curl -sSLO https://github.com/ckaznocha/protoc-gen-lint/releases/download/v${PROTOC_GEN_LINT_VERSION}/protoc-gen-lint_${TARGETOS}_${TARGETARCH}.zip
WORKDIR /protoc-gen-lint-out
RUN unzip -q /protoc-gen-lint_${TARGETOS}_${TARGETARCH}.zip
RUN install -D /protoc-gen-lint-out/protoc-gen-lint /out/usr/bin/protoc-gen-lint
ARG TARGETPLATFORM
RUN xx-verify /out/usr/bin/protoc-gen-lint


FROM --platform=$BUILDPLATFORM alpine_host as upx
RUN mkdir -p /upx 
ARG BUILDARCH BUILDOS UPX_VERSION
RUN if ! [ "${TARGETARCH}" = "arm64" ]; then curl -sSL https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${BUILDARCH}_${BUILDOS}.tar.xz | tar xJ --strip 1 -C /upx; fi
RUN if ! [ "${TARGETARCH}" = "arm64" ]; then install -D /upx/upx /usr/local/bin/upx; fi
COPY --from=googleapis /out/ /out/
COPY --from=grpc_gateway /out/ /out/
COPY --from=grpc_web /out/ /out/
COPY --from=protoc_gen_doc /out/ /out/
COPY --from=protoc_gen_go /out/ /out/
COPY --from=protoc_gen_go_grpc /out/ /out/
COPY --from=protoc_gen_gotemplate /out/ /out/
COPY --from=protoc_gen_govalidators /out/ /out/
COPY --from=protoc_gen_gql /out/ /out/
COPY --from=protoc_gen_jsonschema /out/ /out/
COPY --from=protoc_gen_lint /out/ /out/
COPY --from=protoc_gen_validate /out/ /out/
ARG TARGETARCH
RUN <<EOF
    if ! [ "${TARGETARCH}" = "arm64" ]; then
        upx --lzma $(find /out/usr/bin/ -type f \
            -name 'protoc-gen-*' -or \
            -name 'grpc_*' \
        )
    fi
EOF
RUN find /out -name "*.a" -delete -or -name "*.la" -delete


FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Sebastian Döll <sebastian.doell@ionos.com>"
COPY --from=upx /out/ /
RUN apk add --no-cache \
        bash\
        grpc \
        protobuf \
        protobuf-dev \
        protobuf-c-compiler
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
RUN apk add glibc-2.35-r0.apk --force-overwrite
RUN rm -f glibc-2.35-r0.apk
RUN ln -s /usr/bin/grpc_cpp_plugin /usr/bin/protoc-gen-grpc-cpp
RUN ln -s /usr/bin/grpc_csharp_plugin /usr/bin/protoc-gen-grpc-csharp
RUN ln -s /usr/bin/grpc_objective_c_plugin /usr/bin/protoc-gen-grpc-objc
RUN ln -s /usr/bin/grpc_php_plugin /usr/bin/protoc-gen-grpc-php
RUN ln -s /usr/bin/grpc_python_plugin /usr/bin/protoc-gen-grpc-python
RUN ln -s /usr/bin/grpc_ruby_plugin /usr/bin/protoc-gen-grpc-ruby
RUN ln -s /usr/bin/protoc-gen-go-grpc /usr/bin/protoc-gen-grpc-go
COPY protoc-wrapper /usr/bin/protoc-wrapper
RUN mkdir -p /test
RUN protoc-wrapper \
        --c_out=/test \
        --go_out=/test \
        --gotemplate_out=/test \
        --govalidators_out=/test \
        --gql_out=/test \
        --grpc-cpp_out=/test \
        --grpc-csharp_out=/test \
        --grpc-go_out=/test \
        --grpc-objc_out=/test \
        --grpc-php_out=/test \
        --grpc-python_out=/test \
        --grpc-ruby_out=/test \
        --jsonschema_out=/test \
        --lint_out=/test \
        --php_out=/test \
        --python_out=/test \
        --ruby_out=/test \
        --validate_out=lang=go:/test \
        google/protobuf/any.proto
ARG TARGETARCH
RUN if ! [ "${TARGETARCH}" = "arm64" ]; then apk add --no-cache grpc-java; fi
RUN <<EOF
    if ! [ "${TARGETARCH}" = "arm64" ]; then
        protoc-wrapper \
            --java_out=/test \
            --grpc-java_out=/test \
            google/protobuf/any.proto
    fi
EOF
RUN rm -rf /test
ENTRYPOINT ["protoc-wrapper", "-I/usr/include"]
