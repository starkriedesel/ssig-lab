FROM ctf-apache

# MySQL config file
COPY my.cnf /etc/mysql/my.cnf
COPY init.sql /var/init.sql

# Service file
COPY mysqld.sh /etc/service/mysqld/run
RUN chown root:root /etc/service/mysqld/run && chmod 755 /etc/service/mysqld/run
