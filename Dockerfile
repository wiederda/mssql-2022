FROM ubuntu:22.04
RUN apt-get update -y && apt-get upgrade -y \
&& apt-get -y install wget \
&& apt-get -y install software-properties-common \
&& rm -rf /var/lib/apt/lists/* \
&& wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
&& add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)" \
&& apt-get -y update \
&& apt-get -y install mssql-server mssql-tools unixodbc-dev \
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

# Setze die Standard Shell, die beim Ausführen des Containers verwendet wird
SHELL ["/bin/bash", "-c"] 

USER mssql
CMD ["/opt/mssql/bin/sqlservr"]