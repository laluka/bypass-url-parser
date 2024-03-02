FROM python:3.13.0a2-slim-bullseye

# Sane defaults for pip
ENV \
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y curl bat && \
  ln -sf /usr/bin/batcat /usr/local/bin/bat

# Install dependencies first to leverage Docker layer caching.
RUN --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
  pip install -r /tmp/requirements.txt

RUN --mount=type=bind,source=dist,target=/tmp/app_dist \
  pip install /tmp/app_dist/*.whl --no-deps && pip check

WORKDIR /bup

ENTRYPOINT [ "bypass-url-parser" ]
