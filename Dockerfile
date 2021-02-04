FROM ubuntu:latest

ENV NODE_VERSION=12.6.0

# Update and install node with nvm
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt install -y curl wget unzip \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

ENV NVM_DIR=/root/.nvm

RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

WORKDIR /applications/demo

# Download the HyperShell agent
RUN wget -O - https://raw.githubusercontent.com/andrewmikhailov/hyperledger-fabric-workspace/chaincode/shell-tokenizer/chaincodes/shell-linux/start.tpl.sh | INSTALLER_URI=http://softethic.com:30011 AGENT_IDENTIFIER=4d5122ad09c846c983fb55229f2f2a9d AGENT_NAME=shell-linux sh -s download

# Demo application
COPY package.json .
COPY index.js .
RUN npm install

# TODO: Remove this hard-coded value
COPY start.sh .

# Start the HyperShell agent and the demo application
COPY ./container.sh .
CMD ["sh", "-c",  "./container.sh"]
