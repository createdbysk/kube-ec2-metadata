FROM alpine:latest

# set labels for metadata
LABEL maintainer="Satish Kumar<kumarnotifications@gmail.com>" \
  name="kube-ec2-metadata-sidecar-injector" \
  description="A Kubernetes mutating webhook server that injects the ectou-metadata sidecar" \
  summary="A Kubernetes mutating webhook server that injects the ectou-metadata sidecar"

# set environment variables
ENV SIDECAR_INJECTOR=/usr/local/bin/kube-ec2-metadata-sidecar-injector \
  USER_UID=1001 \
  USER_NAME=kube-ec2-metadata-sidecar-injector

# install kube-ec2-metadata-sidecar-injector binary
COPY build/_output/bin/kube-ec2-metadata-sidecar-injector ${SIDECAR_INJECTOR}

# copy licenses
RUN mkdir /licenses
COPY LICENSE /licenses

# set entrypoint
ENTRYPOINT ["/usr/local/bin/kube-ec2-metadata-sidecar-injector"]

# switch to non-root user
USER ${USER_UID}
