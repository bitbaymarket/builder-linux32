
FROM ubuntu:trusty

ENV ARCH x86
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt install -y make
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install --no-install-recommends -y gcc-7-multilib g++-7-multilib
RUN apt-get update
RUN add-apt-repository -y ppa:beineri/opt-qt593-trusty 
RUN add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y libdb4.8-dev:i386
RUN apt-get install -y libdb4.8++-dev:i386
RUN apt-get install -y libboost-filesystem-dev:i386
RUN apt-get install -y libboost-program-options-dev:i386
RUN apt-get install -y libboost-thread-dev:i386
RUN apt-get install -y libssl-dev:i386
RUN apt-get install -y libgl1-mesa-dev:i386
RUN apt-get install -y libminiupnpc-dev:i386
RUN apt-get install -y libfuse-dev:i386

RUN ln -s /usr/bin/g++-7 /usr/bin/g++
RUN ln -s /usr/bin/gcc-7 /usr/bin/gcc

RUN mkdir -p /mnt
WORKDIR /mnt

RUN gcc -v

RUN apt-get install -y patch
COPY fix_multiprecision.patch /mnt/
RUN cd /usr && patch -p1 < /mnt/fix_multiprecision.patch

RUN apt-get install -y libqrencode-dev:i386
RUN apt-get install -y qt59-meta-minimal:i386
RUN apt-get install -y qt59tools:i386

RUN apt-get install -y curl
RUN apt-get install -y fuse
RUN chmod 644 /etc/fuse.conf

ENV BASE1 https://github.com/bitbaymarket/bitbay-prebuilt-libs1/releases/download/base1
#RUN curl -fsSL -o /usr/bin/linuxdeployqt $BASE1/linuxdeployqt-continuous-x86_64.AppImage
#RUN chmod 755 /usr/bin/linuxdeployqt

RUN curl -fsSL -o appimagetool $BASE1/appimagetool-i686.AppImage
RUN chmod 755 appimagetool
RUN mv appimagetool /usr/bin

RUN curl -fsSL -o linuxdeployqt-continuous.tar.gz $BASE1/linuxdeployqt-continuous.tar.gz
RUN tar -zxf linuxdeployqt-continuous.tar.gz

WORKDIR /mnt/linuxdeployqt-continuous
RUN bash -c "export PATH=`pwd`:$PATH && source /opt/qt59/bin/qt59-env.sh && export && qmake QMAKE_CFLAGS+=-m32 QMAKE_CXXFLAGS+=-m32 QMAKE_LFLAGS+=-m32 && make -j2"
RUN ls -al bin
RUN mv bin/linuxdeployqt /usr/bin

WORKDIR /mnt
RUN rm -rf linuxdeployqt-continuous*
RUN ls -al
