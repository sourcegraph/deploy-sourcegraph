# This Dockerfile tracks jaegertracing/all-in-one, but includes more debugging tools and runs as a
# non-root user. It requires JAEGER_VERSION to be set as an argument to build.
ARG JAEGER_VERSION
FROM jaegertracing/all-in-one:$JAEGER_VERSION as base

FROM alpine:3.11.5
RUN apk update
RUN apk add bash curl

COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=base /go/bin/all-in-one-linux  /go/bin/all-in-one-linux
COPY --from=base /etc/jaeger/sampling_strategies.json /etc/jaeger/sampling_strategies.json

RUN adduser -S -u 10001 jaeger
RUN chown jaeger /go/bin/all-in-one-linux
RUN chown jaeger /etc/jaeger/sampling_strategies.json
USER jaeger

# Agent zipkin.thrift compact
EXPOSE 5775/udp

# Agent jaeger.thrift compact
EXPOSE 6831/udp

# Agent jaeger.thrift binary
EXPOSE 6832/udp

# Agent config HTTP
EXPOSE 5778

# Collector HTTP
EXPOSE 14268

# Collector gRPC
EXPOSE 14250

# Web HTTP
EXPOSE 16686

VOLUME ["/tmp"]
ENTRYPOINT ["/go/bin/all-in-one-linux"]
CMD ["--sampling.strategies-file=/etc/jaeger/sampling_strategies.json"]
