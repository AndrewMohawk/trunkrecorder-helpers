
#Download base image ubuntu 20.04
FROM ubuntu:20.04
RUN apt update -y 
RUN apt upgrade -y
#RUN apt install 

#BladeRF Repo
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:nuandllc/bladerf


RUN apt install -y gr-osmosdr osmo-sdr libosmosdr0 libosmosdr-dev libuhd3.15.0 libuhd-dev gnuradio-dev libgnuradio-uhd3.8.1 libgnuradio-osmosdr0.2.0 hackrf libhackrf-dev libhackrf0 git gcc cpp cmake make build-essential libboost-all-dev libusb-1.0-0 libusb-dev fdkaac libfdk-aac-dev libfdk-aac1 libsox3 libsox-dev libsoxr0 sox ffmpeg libaacs0 libcppunit-dev libcppunit-1.15-0 libvo-aacenc0 libssl-dev openssl curl libcurl4 libcurl4-openssl-dev gnuradio libuhd-dev libcurl3-gnutls bladerf libbladerf-dev libtecla1  libncurses5-dev libtecla-dev pkg-config wget liborc-0.4-dev autoconf automake build-essential libass-dev libfreetype6-dev libtool pkg-config texinfo zlib1g-dev yasm libfdk-aac-dev


RUN apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


#Packages done, lets clone and build trunkrecorder with Patches
RUN mkdir /trunk-recorder-build/
WORKDIR /trunk-recorder-build/
RUN git clone https://github.com/robotastic/trunk-recorder.git .
RUN mkdir /trunk-recorder-build/patches/
COPY patches/* /trunk-recorder-build/patches/
RUN ls /trunk-recorder-build/patches/*.patch
RUN cat /trunk-recorder-build/patches/*.patch | patch -p1
RUN mkdir -p /trunk-recorder-build/build/
WORKDIR /trunk-recorder-build/build/

RUN cmake ../
RUN make 
RUN mkdir /app && cp ./recorder /app/trunk-recorder
RUN ls -lisah /app
RUN mkdir -p /app/media
RUN mkdir -p /app/config

#Lets copy all the config files over
COPY config/config.json /app/config/config.json
COPY config/talkgroup-trunkrecorder-format.csv /app/

#Set GR to info only
RUN sed -i 's/log_level = debug/log_level = info/g' /etc/gnuradio/conf.d/gnuradio-runtime.conf 

WORKDIR /app
CMD ["./trunk-recorder","--config=/app/config/config.json"]





