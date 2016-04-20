FROM ubuntu:14.04.3

MAINTAINER Bo-Yi Wu <appleboy.tw@gmail.com>

RUN apt-get update
RUN apt-get -y install git g++ make libncurses5-dev subversion libssl-dev gawk libxml-parser-perl unzip wget python xz-utils
RUN cd /root && git clone git://git.openwrt.org/15.05/openwrt.git

WORKDIR /root/openwrt

RUN cp feeds.conf.default feeds.conf
RUN echo src-git linkit https://github.com/MediaTek-Labs/linkit-smart-7688-feed.git >> feeds.conf
RUN ./scripts/feeds update
RUN ./scripts/feeds install -a

CMD /bin/bash
