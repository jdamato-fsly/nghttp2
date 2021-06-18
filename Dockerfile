FROM us.gcr.io/plat-elevation-preprod/fastly/base:latest

ARG DESTDIR=/build
ARG PKG_VERSION=0.dev

WORKDIR /build
COPY . .

RUN apt-get update && apt-get -y install fst-ffpm=1.1-5 automake build-essential libtool libc-ares-dev libc-ares2 libev-dev fst-libssl1.1 fst-libssl1.1-dev
RUN cd fastly-build && ./stage-2-pbuilder.sh
RUN /opt/fst-ffpm/bin/ffpm -s dir -t deb -n fst-nghttp2 -v ${PKG_VERSION} -C /build -p ${DESTDIR}/fst-nghttp2-VERSION_ARCH.deb /opt
