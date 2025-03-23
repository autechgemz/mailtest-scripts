ARG VARIANT
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

ARG DEBIAN_FRONTEND=noninterractive
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    expect \
    telnet

ARG DEV_USER
USER $DEV_USER

RUN curl -fsSL https://bun.sh/install | bash
