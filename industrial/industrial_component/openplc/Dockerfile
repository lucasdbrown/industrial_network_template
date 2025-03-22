FROM ubuntu:xenial

USER root
WORKDIR /root/

# Update package list & install dependencies
RUN apt-get update
RUN apt-get install -y build-essential \
    libpcap-dev \
    libdnet-dev \
    libevent-dev \
    libpcre3-dev \
    make \
    bzip2 \
    nmap \
    psmisc \
    libtool \
    libdumbnet-dev \
    zlib1g-dev \
    rrdtool \
    net-tools \
    git-core \
    libreadline-dev \
    libedit-dev \
    bison \
    flex \
    farpd \
    lftp \
    iputils-ping \
    sudo \
    automake \
    sqlite3

RUN sudo apt-get install -y build-essential pkg-config bison flex autoconf automake libtool make nodejs git
# Copy OpenPLC
COPY OpenPLC_v2 /home/OpenPLC_v2
WORKDIR /home/OpenPLC_v2/
RUN sudo chmod +x ./build.sh
# RUN ./build.sh


EXPOSE 502
EXPOSE 8080

# CMD sudo nodejs /OpenPLC_v2/server.js
CMD ./build.sh && sudo nodejs server.js
