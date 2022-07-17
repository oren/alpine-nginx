#!/usr/bin/env bash

OS=""
MYUPGRADE="0"

DectectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then
      OS="ubuntu"
    fi
    if grep -q "NAME=\"CentOS Linux\"" /etc/os-release ; then
      OS="centos"
    fi
  fi
}

AutoUpgrade(){
  if [ "$(id -u)" = '0' ]; then
    if [ -n "${DOCKUPGRADE}" ]; then
      MYUPGRADE="${DOCKUPGRADE}"
    fi
    if [ "${MYUPGRADE}" == 1 ]; then
      if [ "${OS}" == "alpine" ]; then
        apk --no-cache upgrade
        rm -rf /var/cache/apk/*
      elif [ "${OS}" == "ubuntu" ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get -y --no-install-recommends dist-upgrade
        apt-get -y autoclean
        apt-get -y clean
        apt-get -y autoremove
        rm -rf /var/lib/apt/lists/*
      elif [ "${OS}" == "centos" ]; then
        yum upgrade -y
        yum clean all
        rm -rf /var/cache/yum/*
      fi
    fi
  fi
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

DockLog(){
  if [ "${OS}" == "centos" ] || [ "${OS}" == "alpine" ]; then
    echo "${1}"
  else
    logger "${1}"
  fi
}

DectectOS
AutoUpgrade

if [ "${1}" == 'certbot' ]; then
  if [ -z "${DOCKMAIL}" ]; then
    DockLog "ERROR: administrator email is mandatory"
  elif [ -z "${DOCKDOMAINS}" ]; then
    DockLog "ERROR: at least one domain must be specified"
  else
    exec certbot certonly --verbose --noninteractive --quiet --standalone --agree-tos --email="${DOCKMAIL}" -d "${DOCKDOMAINS}" 
  fi
elif [ "${1}" == 'certbot-renew' ]; then
   exec certbot renew
else
  "$@"
fi

nginx