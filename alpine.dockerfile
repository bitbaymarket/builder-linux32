# Build stage for BerkeleyDB
FROM multiarch/alpine:i386-v3.8 as berkeleydb

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

FROM multiarch/alpine:i386-v3.8 as qt-dev

COPY --from=berkeleydb /opt /opt

RUN apk add --no-cache tree
RUN tree /opt

WORKDIR /
RUN apk add --no-cache abuild
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add gcc
RUN apk --no-cache add alpine-sdk

RUN apk add --no-cache openssl-dev
RUN apk add --no-cache at-spi2-atk-dev
RUN apk add --no-cache bison
RUN apk add --no-cache cups-dev
RUN apk add --no-cache eudev-dev
RUN apk add --no-cache flex
RUN apk add --no-cache freetds-dev
RUN apk add --no-cache gawk
RUN apk add --no-cache gperf
RUN apk add --no-cache gtk+2.0-dev
RUN apk add --no-cache icu-dev
RUN apk add --no-cache libinput-dev
RUN apk add --no-cache libjpeg-turbo-dev
RUN apk add --no-cache libxkbcommon-dev
RUN apk add --no-cache libxrandr-dev
RUN apk add --no-cache libxrender-dev
RUN apk add --no-cache libxslt-dev
RUN apk add --no-cache libxv-dev
RUN apk add --no-cache freetype-static
RUN apk add --no-cache mtdev-dev
RUN apk add --no-cache pcre2-dev
RUN apk add --no-cache libice-dev
RUN apk add --no-cache libsm-dev

RUN rm -rf /usr/lib/libfreetype.so*
RUN rm -rf /usr/lib/libX11-xcb.so*
RUN rm -rf /usr/lib/libxcb.so*
RUN rm -rf /usr/lib/libX11.so*
RUN rm -rf /usr/lib/libSM.so*
RUN rm -rf /usr/lib/libICE.so*
RUN rm -rf /usr/lib/libxkbcommon-x11.so*
RUN rm -rf /usr/lib/libxkbcommon.so*
RUN rm -rf /usr/lib/libXau.so*
RUN rm -rf /usr/lib/libXdmcp.so*
RUN rm -rf /usr/lib/libuuid.so*
RUN rm -rf /usr/lib/libxcb-xkb.so*
RUN rm -rf /usr/lib/libpcre.so*

RUN     mkdir -p /var/cache/distfiles && \
        adduser -D packager && \
        addgroup packager abuild && \
        chgrp abuild /var/cache/distfiles && \
        chmod g+w /var/cache/distfiles && \
        echo "packager    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD     setup.sh /home/packager/bin/setup.sh

WORKDIR /work

USER packager
RUN abuild-keygen -a

COPY qt5-qtbase /work/qt5-qtbase
RUN sudo chown -R packager /work 
WORKDIR /work/qt5-qtbase

RUN abuild -r

RUN tree /home/packager
RUN sudo mkdir /opt/qt
RUN sudo mv /home/packager/packages/work/x86/* /opt/qt/

FROM multiarch/alpine:i386-v3.8 as qt-tools

COPY --from=qt-dev /opt /opt

RUN apk add --no-cache tree
RUN tree /opt

RUN apk add --allow-untrusted /opt/qt/qt5-qtbase-dev-5.12.1-r2.apk
RUN apk --no-cache add gcc
RUN apk --no-cache add g++
RUN apk --no-cache add make
RUN apk --no-cache add libxrender

RUN apk add --no-cache at-spi2-atk-dev
RUN apk add --no-cache bison
RUN apk add --no-cache cups-dev
RUN apk add --no-cache eudev-dev
RUN apk add --no-cache flex
RUN apk add --no-cache freetds-dev
RUN apk add --no-cache gawk
RUN apk add --no-cache gperf
RUN apk add --no-cache gtk+2.0-dev
RUN apk add --no-cache icu-dev
RUN apk add --no-cache libinput-dev
RUN apk add --no-cache libjpeg-turbo-dev
RUN apk add --no-cache libxkbcommon-dev
RUN apk add --no-cache libxrandr-dev
RUN apk add --no-cache libxrender-dev
RUN apk add --no-cache libxslt-dev
RUN apk add --no-cache libxv-dev
RUN apk add --no-cache mtdev-dev
RUN apk add --no-cache pcre2-dev
RUN apk add --no-cache libc-dev
RUN apk add --no-cache libgcc
RUN apk add --no-cache musl-dev

RUN apk add --no-cache abuild
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add alpine-sdk

RUN cp /usr/lib/libxcb-static.a /libxcb-static.a
RUN cp /usr/lib/libqtlibpng.a /libqtlibpng.a
RUN cp /usr/lib/libqtpcre2.a /libqtpcre2.a 
RUN cp /usr/lib/libqtfreetype.a /libqtfreetype.a 
RUN cp /usr/lib/libqtharfbuzz.a /libqtharfbuzz.a 

WORKDIR /

RUN     mkdir -p /var/cache/distfiles && \
        adduser -D packager && \
        addgroup packager abuild && \
        chgrp abuild /var/cache/distfiles && \
        chmod g+w /var/cache/distfiles && \
        echo "packager    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD     setup.sh /home/packager/bin/setup.sh

WORKDIR /work

USER packager
RUN abuild-keygen -a

COPY qt5-qttools /work/qt5-qttools
RUN sudo chown -R packager /work 
WORKDIR /work/qt5-qttools

RUN abuild -r

RUN tree /home/packager
RUN sudo mkdir /opt/qttools
RUN sudo mv /home/packager/packages/work/x86/* /opt/qttools/

FROM multiarch/alpine:i386-v3.8 as boost-dev
COPY --from=qt-tools /opt /opt

RUN apk --no-cache add tree
RUN tree /opt/

WORKDIR /
RUN apk add --no-cache abuild
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add gcc
RUN apk --no-cache add alpine-sdk

RUN apk --no-cache add linux-headers
RUN apk --no-cache add python2-dev
RUN apk --no-cache add python3-dev
RUN apk --no-cache add flex
RUN apk --no-cache add bison
RUN apk --no-cache add bzip2-dev
RUN apk --no-cache add zlib-dev


RUN     mkdir -p /var/cache/distfiles && \
        adduser -D packager && \
        addgroup packager abuild && \
        chgrp abuild /var/cache/distfiles && \
        chmod g+w /var/cache/distfiles && \
        echo "packager    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD     setup.sh /home/packager/bin/setup.sh

WORKDIR /work

USER packager
RUN abuild-keygen -a

COPY boost /work/boost
RUN sudo chown -R packager /work 
WORKDIR /work/boost

# /var/cache/distfiles/
COPY boost_1_62_0.tar.gz /var/cache/distfiles/boost_1_62_0.tar.gz
RUN abuild -r || ls -al /work/boost/pkg/boost/usr/lib/

RUN tree /home/packager
RUN sudo mkdir /opt/boost
RUN sudo mv /home/packager/packages/work/x86/* /opt/boost/

FROM multiarch/alpine:i386-v3.8 as bitbay-dev

COPY --from=boost-dev /opt /opt

RUN apk add --no-cache tree
RUN tree /opt

RUN apk add --allow-untrusted /opt/boost/boost-*.apk
RUN apk add --allow-untrusted /opt/qt/qt5-qtbase-dev-5.12.1-r2.apk
RUN apk add --allow-untrusted /opt/qttools/qt5-qttools-5.12.1-r0.apk
RUN apk add --allow-untrusted /opt/qttools/qt5-qttools-dev-5.12.1-r0.apk
RUN apk --no-cache add gcc
RUN apk --no-cache add g++
RUN apk --no-cache add make
RUN apk --no-cache add libxrender

RUN apk add --no-cache at-spi2-atk-dev
RUN apk add --no-cache bison
RUN apk add --no-cache cups-dev
RUN apk add --no-cache eudev-dev
RUN apk add --no-cache flex
RUN apk add --no-cache freetds-dev
RUN apk add --no-cache gawk
RUN apk add --no-cache gperf
RUN apk add --no-cache gtk+2.0-dev
RUN apk add --no-cache icu-dev
RUN apk add --no-cache libinput-dev
RUN apk add --no-cache libjpeg-turbo-dev
RUN apk add --no-cache libxkbcommon-dev
RUN apk add --no-cache libxrandr-dev
RUN apk add --no-cache libxrender-dev
RUN apk add --no-cache libxslt-dev
RUN apk add --no-cache libxv-dev
RUN apk add --no-cache mtdev-dev
RUN apk add --no-cache pcre2-dev
RUN apk add --no-cache libc-dev
RUN apk add --no-cache libgcc
RUN apk add --no-cache musl-dev

RUN ls /usr/lib/libQt*

RUN ls /usr/lib/lib*.a

RUN cp /usr/lib/libxcb-static.a /libxcb-static.a
RUN cp /usr/lib/libqtlibpng.a /libqtlibpng.a
RUN cp /usr/lib/libqtpcre2.a /libqtpcre2.a 
RUN cp /usr/lib/libqtfreetype.a /libqtfreetype.a 
RUN cp /usr/lib/libqtharfbuzz.a /libqtharfbuzz.a 


RUN qmake-qt5 -v

COPY qtapp /qtapp
WORKDIR /qtapp
RUN qmake-qt5
RUN make


RUN ldd qtapp

#RUN apk add --no-cache packagename=1.2.3-suffix
RUN apk add --no-cache miniupnpc-dev

RUN cp -avR /opt/db-4.8.30.NC/include/* /usr/include/
RUN cp -avR /opt/db-4.8.30.NC/lib/* /usr/lib/

#RUN rm -rf /lib/libssl.so*
#RUN rm -rf /lib/libcrypto.so*
#RUN rm -rf /usr/lib/libminiupnpc.so*
#RUN rm -rf /usr/lib/libboost*.so*

RUN apk add --no-cache curl
RUN apk add --no-cache tar
RUN apk add --no-cache vim
RUN apk add --no-cache dev86

