FROM ubuntu:22.04

# Setze Umgebungsvariablen für das Passwort und die Acceptance des EULAs
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrongPassword

RUN apt-get update -y && apt-get upgrade -y \
&& apt-get -y install wget \
&& apt-get -y install software-properties-common \
&& rm -rf /var/lib/apt/lists/* \
&& wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
&& add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)" \
&& apt-get -y update \
&& apt-get -y install mssql-server \
&& userdel mssql \
&& useradd -M -s /bin/bash -u 10001 -g 0 mssql \
&& mkdir -p -m 770 /var/opt/mssql && chgrp -R 0 /var/opt/mssql \
&& chown -R mssql:root /var/opt/mssql \
 
# Grant sql the permissions to connect to ports <1024 as a non-root user
#
&& setcap 'cap_net_bind_service+ep' /opt/mssql/bin/sqlservr \
 
# Allow dumps from the non-root process
# 
&& setcap 'cap_sys_ptrace+ep' /opt/mssql/bin/paldumper \
&& setcap 'cap_sys_ptrace+ep' /usr/bin/gdb \
 
# Add an ldconfig file because setcap causes the os to remove LD_LIBRARY_PATH
# and other env variables that control dynamic linking
#
&& mkdir -p /etc/ld.so.conf.d && touch /etc/ld.so.conf.d/mssql.conf \
&& echo -e "# mssql libs\n/opt/mssql/lib" >> /etc/ld.so.conf.d/mssql.conf \
&& ldconfig \
&& apt-get -y remove wget

# Installiere erforderliche Pakete und das mssql-tools Paket
RUN apt-get update && \
    apt-get install -y curl gnupg2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update && \
    apt-get install -y mssql-tools unixodbc-dev

USER mssql
CMD ["/opt/mssql/bin/sqlservr"]