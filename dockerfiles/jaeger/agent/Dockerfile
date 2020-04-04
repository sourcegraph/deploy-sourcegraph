# This Dockerfile tracks jaegertracing/jaeger-agent, but includes more debugging tools and runs as a
# non-root user. It requires JAEGER_VERSION to be set as an argument to build.
ARG JAEGER_VERSION
FROM jaegertracing/jaeger-agent:$JAEGER_VERSION as base

FROM alpine:3.11.5
RUN apk update
RUN apk add bash curl

COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=base /go/bin/agent-linux /go/bin/agent-linux

RUN adduser -S -u 10001 jaeger
RUN chown jaeger /go/bin/agent-linux
USER jaeger

EXPOSE 5775/udp 6831/udp 6832/udp 5778
ENTRYPOINT ["/go/bin/agent-linux"]
