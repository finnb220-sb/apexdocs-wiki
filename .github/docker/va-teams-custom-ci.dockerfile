FROM salesforce/cli:latest-full

ARG NODE_VERSION=18

  # bash will load volta() function via .bashrc
  # using $VOLTA_HOME/load.sh
SHELL ["/bin/bash", "-c"]

  # since we're starting non-interactive shell,
  # we will need to tell bash to load .bashrc manually
ENV BASH_ENV ~/.bashrc
  # needed by volta() function
ENV VOLTA_HOME /root/.volta
  # make sure packages managed by volta will be in PATH
ENV PATH $VOLTA_HOME/bin:$PATH

  # Install Volta, Node.js, npm, bun etc.
  # In the same layer also install:
  # Sfdx scanner, sfdx git delta, and lightning-flow-scanner plugins
  # Finally cleanup the apt lists to save space.
RUN curl https://get.volta.sh | bash &&\
volta install node@$NODE_VERSION npm prettier bun &&\
sf plugins install @salesforce/sfdx-scanner &&\
echo y | sf plugins install lightning-flow-scanner sfdx-git-delta &&\
rm -rf /var/lib/apt/lists/*

