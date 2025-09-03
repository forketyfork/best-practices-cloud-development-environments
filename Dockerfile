FROM ubuntu:22.04

ARG PUBLIC_KEY
ARG SSH_USER
ARG REPOSITORY

# create a non-root user and group for SSH, adjust permissions for sshd to write login records
RUN groupadd --gid 1000 "$SSH_USER" \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash "$SSH_USER"

WORKDIR "/home/$SSH_USER"

# temporary fix for the Java + Docker + arm64 issue
ENV _JAVA_OPTIONS=-XX:UseSVE=0

# install OpenSSH server and generate host keys
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    openssh-server \
    git \
    openjdk-21-jdk \
  && mkdir -p /opt/ssh \
  && ssh-keygen -q -N "" -t rsa -b 4096 -f /opt/ssh/ssh_host_rsa_key \
  && chown -R "$SSH_USER":"$SSH_USER" /opt/ssh \
  && mkdir /run/sshd \
  && rm -rf /var/lib/apt/lists/*

# set permissions and write public key to authorized_keys
RUN mkdir -p "/home/$SSH_USER/.ssh" \
  && echo "$PUBLIC_KEY" > "/home/$SSH_USER/.ssh/authorized_keys" \
  && chmod 600 "/home/$SSH_USER/.ssh/authorized_keys" \
  && chown "$SSH_USER":"$SSH_USER" "/home/$SSH_USER/.ssh/authorized_keys"

USER "$SSH_USER"

RUN git clone "$REPOSITORY"

EXPOSE 2222

RUN cat <<EOF > "/home/$SSH_USER/.bashrc"
# temporary fix for the Java + Docker + arm64 issue
export _JAVA_OPTIONS=-XX:UseSVE=0
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
EOF

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-p", "2222", "-o", "HostKey=/opt/ssh/ssh_host_rsa_key", "-o", "PidFile=/opt/ssh/sshd.pid"]
