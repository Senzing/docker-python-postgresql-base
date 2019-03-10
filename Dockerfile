ARG BASE_CONTAINER=alpine:3.9
FROM ${BASE_CONTAINER}

ENV REFRESHED_AT=2019-03-09

LABEL Name="senzing/python-postgresql-base" \
      Version="1.0.0"

# Alpine package repository: https://pkgs.alpinelinux.org/packages

RUN apk --update add \
    bash \
    postgresql-client \
    python \
#   python-dev \
    py-pip \
#   build-base \
 && rm -rf /var/cache/apk/*
 
ENV SENZING_ROOT=/opt/senzing
ENV PYTHONPATH=${SENZING_ROOT}/g2/python
ENV LD_LIBRARY_PATH=${SENZING_ROOT}/g2/lib
 
 
# Copy files from repository.

COPY ./rootfs /

# Runtime execution.

# ENTRYPOINT ["/app/docker-entrypoint.sh"]
# CMD ["python"]
CMD ["/bin/sh"]
