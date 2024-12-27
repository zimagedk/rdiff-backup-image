FROM ubuntu:25.04

RUN apt-get update && \
    apt-get install -y \
        rdiff-backup \
        openssh-server; \
    apt-get clean
    
RUN ssh-keygen -A

# Delete the backup user, as this name is likely to be chosen for a backup service account
RUN deluser backup > /dev/null 2>&1

EXPOSE 22

ENV USER_NAME=
ENV USER_HOME=
ENV USER_ID=1001
ENV GROUP_ID=1001

COPY init.sh /

ENTRYPOINT ["/init.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e"]
