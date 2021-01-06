#!/usr/bin/env sh

# Generate random 8 symbols password
_randPass() {
    head -c 8 /dev/urandom | xxd -p
}

# Check environment variables and set default values
_checkEnv() {
    certdir="/etc/ocserv/cert"
    if [ -z "${OC_CERT}" ] || [ -z "${OC_KEY}" ]; then
        echo "Error: Variables 'OC_CERT' or 'OC_KEY' is not specified!"
        exit 1
    elif [ ! -f ${certdir}/${OC_CERT} ] || [ ! -f ${certdir}/${OC_KEY} ]; then
            echo "Error: not found certificate or key file!"
            exit 1
    else
        if [ -z "${OC_MAXCL}" ]; then
            export OC_MAXCL="4"
        fi
        if [ -z "${OC_MAXSCL}" ]; then
            export OC_MAXSCL="2"
        fi
        if [ -z "${OC_NETWORK}" ]; then
            export OC_NETWORK="10.24.35.0"
        fi
    fi
}

# Preparing system parameters
_sysPrep() {
    if [ ! -e /dev/net/tun ]; then
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200
        chmod 600 /dev/net/tun
    fi
    iptables -t nat -A POSTROUTING -j MASQUERADE
    iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

# Create specified users or a test user
_credCreate() {
    rm -f /etc/ocserv/passwd
    if [ -z "${OC_SECRET}" ]; then
        randpass=$(_randPass)
        echo "${randpass}" | ocpasswd -c /etc/ocserv/passwd user
        echo -e "\nWarning: 'OC_SECRET' variable is not specified! Using random password:\nlogin: user\npass: ${randpass}\n"
    else
        num=`echo ${OC_SECRET} | sed 's/,/\n/g' | wc -l`
        for n in $(seq ${num}); do
            user=`echo ${OC_SECRET} | sed 's/,/\n/g' | sed -n ${n}p | cut -d: -f1`
            pass=`echo ${OC_SECRET} | sed 's/,/\n/g' | sed -n ${n}p | cut -d: -f2`
            echo "${pass}" | ocpasswd -c /etc/ocserv/passwd "${user}"
        done
    fi
}

# Amending variables in config file
_configAmend() {
    sed -i 's/_cert_/'"${OC_CERT}"'/g' /etc/ocserv/ocserv.conf && \
    sed -i 's/_key_/'"${OC_KEY}"'/g' /etc/ocserv/ocserv.conf && \
    sed -i 's/_maxcl_/'"${OC_MAXCL}"'/g' /etc/ocserv/ocserv.conf && \
    sed -i 's/_maxscl_/'"${OC_MAXSCL}"'/g' /etc/ocserv/ocserv.conf && \
    sed -i 's/_net_/'"${OC_NETWORK}"'/g' /etc/ocserv/ocserv.conf
}

# Starting ocserv
_startOCserv() {
    if (pgrep -fl ocserv >/dev/null 2>&1); then
        echo "Info: ocserv process already running, killing..."
        pkill -9 ocserv
    fi
    ocserv -f -c /etc/ocserv/ocserv.conf -d 1 &
    sleep 1
    echo "Info: ocserv process started!"
}

# Checking process is running
_healthCheck() {
    while (pgrep -fl ocserv >/dev/null 2>&1)
    do
        sleep 5
    done
    echo "Error: ocserv is not running, exiting..."
    exit 1
}

_checkEnv
_sysPrep
_credCreate
_configAmend
_startOCserv
_healthCheck

