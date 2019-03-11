ARG BASE_IMAGE=alpine:3.9
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2019-03-09

LABEL Name="senzing/python-postgresql-base" \
      Version="1.0.0"

# Alpine package repository: https://pkgs.alpinelinux.org/packages

RUN apk --update add \
    bash \
    gcompat \
    krb5-libs \
    libgcc \
    libstdc++ \
    openssl-dev \
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
