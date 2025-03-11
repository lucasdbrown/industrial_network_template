FROM ubuntu:24.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /root/

# Update package list & install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpcap-dev \
    libevent-dev \
    libpcre3-dev \
    make \
    bzip2 \
    nmap \
    psmisc \
    zlib1g-dev \
    rrdtool \
    net-tools \
    git \
    libreadline-dev \
    libedit-dev \
    bison \
    flex \
    iputils-ping \
    automake \
    sqlite3 \
    pkg-config \
    autoconf \
    libtool \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Clone OpenPLC repository
WORKDIR /home/
RUN git clone https://github.com/thiagoralves/OpenPLC_v2

# Set up OpenPLC
WORKDIR /home/OpenPLC_v2/
RUN chmod +x ./build.sh
RUN printf "n\n1\n" | ./build.sh

# Expose OpenPLC ports
EXPOSE 502
EXPOSE 8080

