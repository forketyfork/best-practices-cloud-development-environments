FROM ubuntu:24.04

ARG PUBLIC_KEY
ARG SSH_USER
ARG REPOSITORY

# create a non-root user and group for SSH, adjust permissions for sshd to write login records
RUN (groupadd --gid 1001 "$SSH_USER" || true) \
    && useradd --uid 1001 --gid 1001 --create-home --shell /bin/bash "$SSH_USER"

WORKDIR "/home/$SSH_USER"

# temporary fix for the Java + Docker + arm64 issue - only set on ARM64
RUN if [ "$(uname -m)" = "aarch64" ]; then echo 'export _JAVA_OPTIONS=-XX:UseSVE=0' >> /etc/environment; fi

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

RUN if [ "$(uname -m)" = "aarch64" ]; then \
    echo "# temporary fix for the Java + Docker + arm64 issue" > "/home/$SSH_USER/.bashrc" && \
    echo "export _JAVA_OPTIONS=-XX:UseSVE=0" >> "/home/$SSH_USER/.bashrc" && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64" >> "/home/$SSH_USER/.bashrc"; \
else \
    echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" > "/home/$SSH_USER/.bashrc"; \
fi

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-p", "2222", "-o", "HostKey=/opt/ssh/ssh_host_rsa_key", "-o", "PidFile=/opt/ssh/sshd.pid"]
