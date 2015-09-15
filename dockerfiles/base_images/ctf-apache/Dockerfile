# Phusion BaseImage
FROM phusion/baseimage:0.9.17
CMD ["/sbin/my_init"]

# Install Apache
RUN apt-get update && apt-get -y install lamp-server^
ENV APACHE_RUN_USER ww-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Enable SSL
#RUN /bin/ln -sf ../sites-available/default-ssl /etc/apache2/sites-enabled/001-default-ssl && /bin/ln -sf ../mods-available/ssl.conf /etc/apache2/mods-enabled/ && /bin/ln -sf ../mods-available/ssl.load /etc/apache2/mods-enabled/
#EXPOSE 443

# Expose Ports
EXPOSE 80

# Apache Service
COPY httpd.sh /etc/service/httpd/run
RUN chown root:root /etc/service/httpd/run && chmod 755 /etc/service/httpd/run

# Remove index page
RUN rm /var/www/html/index.html

# Custom Apache Settings
COPY 000-default.conf /etc/apache2/sites-available/
COPY challenge_env.conf /etc/apache2/conf-available/
RUN ln -s /etc/apache2/conf-available/challenge_env.conf /etc/apache2/conf-enabled/challenge_env.conf

# Custom PHP Settings
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*