# ocserv-dockerfile
Dockerfile for "ocserv" SSL VPN server on Alpine Linux

Build
-----
```
$ docker build -t grffio/ocserv .
```
- Supported Args: `OCSERV_VER=0.12.2`

Requirements
------------
- SSL Certificate, for example [Let’s Encrypt](https://letsencrypt.org/docs/)

Quick Start
-----------
```
$ docker run --name ocserv -d -p 443:443/tcp -p 443:443/udp \
             -e OC_CERT=domain.crt -e OC_KEY=domain.key     \
             -v /dir-to-cert:/etc/ocserv/cert               \
             -e OC_SECRET="user:P@SSw0rd" grffio/ocserv
```
- Supported Environment variables:
  - `OC_CERT` - SSL Certificate file name, for example domain.crt (required)
  - `OC_KEY` - Private key file name, for example domain.key (required)
  - `OC_MAXCL` - Limit the number of clients (default: 4)
  - `OC_MAXSCL` - Limit the number of identical clients (default: 2)
  - `OC_NETWORK` - The pool of addresses that leases will be given from (default: 10.24.35.0)
  - `OC_SECRET` - Login and password for ocserv users, format: user1:pass1,user2:pass2 (desirable)

- Exposed Ports:
  - 443/tcp 443/udp