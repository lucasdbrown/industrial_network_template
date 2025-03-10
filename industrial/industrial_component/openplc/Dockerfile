FROM ubuntu:20.04

WORKDIR /home/
RUN sudo apt-get install -y build-essential pkg-config bison flex autoconf automake libtool make nodejs git
RUN git clone https://github.com/thiagoralves/OpenPLC_v2

WORKDIR /home/OpenPLC_v2/
RUN sudo chmod +x ./build.sh
RUN printf "n\n1\n" | ./build.sh

# 502 and 8080 are ports for running OpenPLC
EXPOSE 502
EXPOSE 8080