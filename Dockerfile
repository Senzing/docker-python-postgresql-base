ARG BASE_IMAGE=alpine:3.9
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2019-03-09

LABEL Name="senzing/python-postgresql-base" \
      Version="1.0.0"

# Add Alpine repository.

ENV ALPINE_MIRROR "http://dl-cdn.alpinelinux.org/alpine"
RUN echo "${ALPINE_MIRROR}/edge/main" >> /etc/apk/repositories

# Alpine package repository: https://pkgs.alpinelinux.org/packages

RUN apk --update add \
    bash \
    gcompat \
    krb5-libs \
    libcrypto1.1 \
    libgcc \
    libssl1.1 \
    libstdc++ \
    postgresql-client \
    python \
    py-pip \
 && rm -rf /var/cache/apk/*

# Make soft links.

RUN ln -s /lib/libcrypto.so.1.1 /lib/libcrypto.so.10 \
 && ln -s /lib/libssl.so.1.1    /lib/libssl.so.10

# Set environment variables.

ENV SENZING_ROOT=/opt/senzing
ENV PYTHONPATH=${SENZING_ROOT}/g2/python
ENV LD_LIBRARY_PATH=${SENZING_ROOT}/g2/lib

# Copy files from repository.

COPY ./rootfs /

# Runtime execution.

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["python"]
