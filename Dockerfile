FROM registry.internal.exoscale.ch/exoscale/golang:1.10 as build

RUN mkdir -p /go/src/github.com/exoscale/zlocker
ADD . /go/src/github.com/exoscale/zlocker
WORKDIR /go/src/github.com/exoscale/zlocker

RUN make

# -----------------------------------------------------------------------------

FROM registry.internal.exoscale.ch/exoscale/ubuntu:bionic

LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="zlocker" \
      org.label-schema.vendor="Exoscale" \
      org.label-schema.description="Zookeeper based isolated command execution" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url="https://github.com/exoscale/zlocker" \
      org.label-schema.schema-version="1.0"

COPY --from=build /go/src/github.com/exoscale/zlocker/zlocker zlocker

ENTRYPOINT ["./zlocker"]
