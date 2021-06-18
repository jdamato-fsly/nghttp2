FROM us.gcr.io/plat-elevation-preprod/fastly/base:latest

ARG DESTDIR=/build
ARG PKG_VERSION=0.dev


WORKDIR /build
COPY . .

RUN apt-get update && apt-get -y install fst-ffpm=1.1-5 automake build-essential libtool libc-ares-dev libc-ares2 libev-dev fst-libssl1.1 fst-libssl1.1-dev

ENV OPENSSL_CFLAGS="-I/opt/fst-libssl1.1/include/"
ENV OPENSSL_LIBS="-L/opt/fst-libssl1.1/lib -lssl -Wl,-rpath=/opt/fst-libssl1.1/lib -lcrypto -Wl,-rpath=/opt/fst-libssl1.1/lib"

RUN ls -alhrt
RUN ./configure --prefix=/opt/fst-nghttp2 --disable-python-bindings && make DESTDIR=/build && make install
RUN /opt/fst-ffpm/bin/ffpm -s dir -t deb -n fst-nghttp2 -v ${PKG_VERSION} -C /build -p ${DESTDIR}/fst-nghttp2-VERSION_ARCH.deb /opt
