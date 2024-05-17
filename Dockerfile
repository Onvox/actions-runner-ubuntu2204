FROM ubuntu:22.04

# github runner version
ARG GH_RUNNER_VERSION="2.316.1"

# update the base packages
RUN apt-get update -y && apt-get upgrade -y

# create the github user
RUN useradd -m github

# install any dependent packages along with jq to parse API responses
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gettext-base \
    git \
    jq \
    libffi-dev \
    libssl-dev \
    lsb-release \
    openssh-client

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/github && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz

# symlink /opt/hostedtoolcache to ~github/actions-runner/_work/_tool
# see https://github.com/actions/setup-python/issues/551
RUN mkdir -p ~github/actions-runner/_work/_tool
RUN ln -s ~github/actions-runner/_work/_tool /opt/hostedtoolcache

# install github additional dependencies
RUN chown -R github ~github && /home/github/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "github" so all subsequent commands are run as the docker user
USER github

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

