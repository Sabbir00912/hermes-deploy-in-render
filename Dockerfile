# Extend the official Hermes image instead of installing Hermes from an
# outdated Python base image. The official image contains Hermes' pinned
# runtime, system services, and gateway supervisor.
FROM nousresearch/hermes-agent:latest

# Keep the root entrypoint: the official s6 supervisor drops privileges for
# Hermes at runtime. Do not add USER hermes here.
USER root

# Install Daytona SDK in its own virtual environment. Hermes' own Python
# environment is intentionally sealed by the upstream image, so we do not
# modify it or inject packages into it.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv /opt/daytona-venv \
    && /opt/daytona-venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/daytona-venv/bin/pip install --no-cache-dir daytona \
    && /opt/daytona-venv/bin/python -c "from daytona import Daytona; print('Daytona SDK installed')" \
    && ln -s /opt/daytona-venv/bin/python /usr/local/bin/daytona-python

# Hermes stores configuration, API credentials, sessions, skills and memory
# under /opt/data in the official Docker image. Render mounts a persistent
# disk at this exact path through render.yaml.
ENV HERMES_HOME=/opt/data
ENV TZ=Asia/Dhaka

# A Render Background Worker is intended for always-on messaging gateways.
# The official image supervises this gateway process with s6-overlay.
CMD ["gateway", "run"]
