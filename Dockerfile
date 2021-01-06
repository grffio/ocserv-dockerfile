FROM alpine:3.12 as builder
ARG OCSERV_VER="1.1.2"
WORKDIR /ocserv
RUN apk add -U curl g++ gnutls-dev gpgme libev-dev \
    libnl3-dev libseccomp-dev linux-headers \
    linux-pam-dev lz4-dev make readline-dev xz && \
    curl -LO ftp://ftp.infradead.org/pub/ocserv/ocserv-${OCSERV_VER}.tar.xz && \
    tar -xJf ocserv-${OCSERV_VER}.tar.xz -C /ocserv --strip-components=1 && \
    ./configure && make
FROM alpine:3.12
RUN apk add -U gnutls-dev libseccomp-dev lz4-dev libev-dev linux-pam-dev iptables tini
COPY --from=builder /ocserv/src/ocserv /usr/local/bin/
COPY --from=builder /ocserv/src/ocpasswd /usr/local/bin/
COPY --from=builder /ocserv/src/ocserv-worker /usr/local/bin/
COPY ./ocserv.conf /etc/ocserv/
COPY ./run.sh /usr/local/bin/
EXPOSE 443/tcp 443/udp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["run.sh"]
