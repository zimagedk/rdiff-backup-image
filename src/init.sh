#!/usr/bin/env bash

#
# Creates the specified user and its home directory
# Adds any specified public keys to the ~/.ssh/authorized_keys file for the specified user
# If no public keys set, the users password will be the same as the user name
# Executes the specified commands
#

sshd_config="/etc/ssh/sshd_config.d/access.conf"

if [ -z "${USER_NAME:-}" ] || [ -z "${USER_ID:-}" ] || [ -z "${GROUP_ID:-}" ]; then
    echo "USER_NAME, USER_ID and GROUP_ID must be specified"
    exit 1
fi

if [ -z "${USER_HOME:-}" ]; then
    USER_HOME=/home/${USER_NAME}
fi

if ! id -g "${USER_NAME}" > /dev/null 2>&1; then
    addgroup --gid "${GROUP_ID}" "${USER_NAME}"
fi

if [ -e "${USER_HOME}" ] ; then
    chown "${USER_ID}:${GROUP_ID}" "${USER_HOME}"
fi

if ! id -u "${USER_NAME}" > /dev/null 2>&1; then
    adduser --uid "${USER_ID}" \
        --gid "${GROUP_ID}" \
        --home "${USER_HOME}" \
        --comment "Auto generated during first container startup" \
        --disabled-password \
        "${USER_NAME}"
fi

if [ -n "${PUBLIC_KEY:-}" ]; then
    mkdir -p "${USER_HOME}/.ssh"
    echo -e "${PUBLIC_KEY:-}" > "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${USER_NAME}":"${USER_NAME}" "${USER_HOME}"
    chmod -R 700 "${USER_HOME}/.ssh"
    if [ ! -e "${sshd_config}" ]; then
        echo -e "PubkeyAuthentication yes\nPasswordAuthentication no" > "${sshd_config}";
    fi
else
    echo "${USER_NAME}:${USER_NAME}" | chpasswd
fi

exec $@
