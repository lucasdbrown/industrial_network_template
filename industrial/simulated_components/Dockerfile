FROM ubuntu:latest

RUN apt-get update

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

RUN apt-get update \
&& apt-get install -y sudo \
&& apt-get install -y python3 \
&& apt-get install -y iputils-ping \
&& apt-get install -y net-tools \
&& apt-get install -y git \
&& apt-get -y install nano \
&& apt --yes install python3-pip \	
&& pip install pyModbusTCP \
&& apt install telnet \
&& apt-get install -y memcached \
&& apt-get install -y python3-memcache \ 
&& apt-get install -y ettercap-common \
&& apt-get install -y unzip \
&& apt-get install -y nmap \
&& apt-get install -y curl \
&& apt-get install dos2unix

COPY /src /src/

WORKDIR /src

RUN find . -type f -exec dos2unix {} \;

RUN chmod 755 *.*
