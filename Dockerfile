FROM us.gcr.io/plat-elevation-preprod/fastly/base:latest

ARG DESTDIR=/build
ARG PKG_VERSION=0.dev


WORKDIR /build
COPY . .

RUN apt-get update && apt-get -y install fst-ffpm=1.1-5 automake build-essential libtool libc-ares-dev libc-ares2 libev-dev fst-libssl1.1 fst-libssl1.1-dev automake autoconf pkg-config zlib1g zlib1g-dev fst-gcc-9.1.0

ENV OPENSSL_CFLAGS="-I/opt/fst-libssl1.1/include/"
ENV OPENSSL_LIBS="-L/opt/fst-libssl1.1/lib -lssl -Wl,-rpath=/opt/fst-libssl1.1/lib -lcrypto -Wl,-rpath=/opt/fst-libssl1.1/lib"
ENV CC=/opt/fst-gcc/9.1.0/bin/gcc
ENV CXX=/opt/fst-gcc/9.1.0/bin/g++

RUN mkdir output/
RUN ls -alhrt
RUN autoreconf -i && automake && autoconf
RUN ./configure --prefix=/opt/fst-nghttp2 --disable-python-bindings && make && make install DESTDIR=/build/output
RUN /opt/fst-ffpm/bin/ffpm --depdends libev --depends fst-libssl1.1 --depends zlib1g -s dir -t deb -n fst-nghttp2 -v ${PKG_VERSION} -C /build/output -p ${DESTDIR}/fst-nghttp2-VERSION_ARCH.deb opt
