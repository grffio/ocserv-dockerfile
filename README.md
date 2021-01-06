# ocserv-dockerfile
Dockerfile for Openconnect VPN Server on Alpine Linux

Features
--------
- It is possible to specify multiple users with their passwords

Build
-----
```
$ docker build -t grffio/ocserv .
```
- Supported Args: `OCSERV_VER=`

Requirements
------------
- SSL Certificate, for example [Let’s Encrypt](https://letsencrypt.org/docs/)

Quick Start
-----------
```
$ docker run --name ocserv -d -p 443:443/tcp -p 443:443/udp       \
             -v /dir-to-cert:/etc/ocserv/cert --cap-add=NET_ADMIN \
             -e OC_CERT=domain.crt -e OC_KEY=domain.key           \
             -e OC_SECRET="user:P@SSw0rd" grffio/ocserv
```
- Supported Environment variables:
  - `OC_CERT`    - SSL Certificate file name, for example domain.crt (required)
  - `OC_KEY`     - Private key file name, for example domain.key (required)
  - `OC_MAXCL`   - Limit the number of clients (default: 4)
  - `OC_MAXSCL`  - Limit the number of identical clients (default: 2)
  - `OC_NETWORK` - The pool of addresses that leases will be given from (default: 10.24.35.0)
  - `OC_SECRET`  - Login and password for ocserv users, format: user1:pass1,user2:pass2 (desirable)

- Exposed Ports:
  - 443/tcp 443/udp

An example how to use with docker-compose [shadownet-compose](https://github.com/grffio/shadownet-compose)
