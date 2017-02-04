FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ python3 \
              libzmq3-dev libzmqpp-dev libgflags-dev libgtest-dev ruby python git \
              python3-yaml python3-dev ocaml mono-devel openjdk-8-jdk \
              haskell-platform php7.0-dev php7.0 libphp7.0-embed  \
              wget python-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
