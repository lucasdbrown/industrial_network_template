FROM ubuntu:24.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /root/

# Update package list & install dependencies
<<<<<<< HEAD
<<<<<<< HEAD
RUN apt-get update
RUN apt-get install -y build-essential \
=======
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
>>>>>>> parent of 3548ff4 (fix(git-issue): openplc website running again)
=======
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
>>>>>>> parent of 4cff90c (fixing git on computer)
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

<<<<<<< HEAD
<<<<<<< HEAD
RUN sudo apt-get install -y build-essential pkg-config bison flex autoconf automake libtool make nodejs git
=======
>>>>>>> parent of 3548ff4 (fix(git-issue): openplc website running again)
=======
>>>>>>> parent of 4cff90c (fixing git on computer)
# Copy OpenPLC
COPY OpenPLC_v2 /home/OpenPLC_v2

# Set up OpenPLC
WORKDIR /home/OpenPLC_v2/
RUN chmod +x ./build.sh
RUN printf "n\n1\n" | ./build.sh

# Expose OpenPLC ports
EXPOSE 502
EXPOSE 8080

