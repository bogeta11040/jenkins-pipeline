# use a nginx base image
FROM nginx

# set maintainer
LABEL maintainer "igor"

# set a health check
HEALTHCHECK --interval=5s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:8000 || exit 1

# this port is configured previously in AWS
EXPOSE 8000