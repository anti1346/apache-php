FROM centos:7

ENV PS1A="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "

##### PS1 쉘 프롬프트 변경
RUN echo 'PS1=$PS1A' >> ~/.bashrc

##### 시스템 운영에 필요한 패키지 설치, 운영체제 업데이트 및 yum cache 삭제
RUN yum install -q -y epel-release yum-utils \
  # && yum install -y tar unzip vim telnet net-tools curl openssl \
  && yum update -y  \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /var/tmp/* \
  && rm -rf /tmp/*

##### Apache 설치
RUN yum install -q -y httpd httpd-tools \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /var/tmp/* \
  && rm -rf /tmp/*

##### PHP 설치
RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
  && yum-config-manager --enable remi-php74 \
  && yum install -q -y php php-cli php-common php-devel php-pear php-pdo \
    php-bcmath php-opcache php-mbstring php-gd php-json \
    php-xml php-mcrypt php-mysqlnd php-pecl-mcrypt php-pecl-mysql \
  && yes '' | pecl install -f igbinary redis \
  && echo "extension=redis.so" > /etc/php.d/ext-redis.ini \
  && yum install -q -y ImageMagick ImageMagick-devel \
  && yes '' | pecl install -f imagick \
  && echo "extension=imagick.so" > /etc/php.d/ext-imagick.ini \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /var/tmp/* \
  && rm -rf /tmp/*

##### Apache 유저, 그룹, 기본설정(ServerName), Apache PHP 연동 설정, Apache PHP 버전 숨기기, phpinfo.php 페이지 생성
RUN sed -i "s/`grep '^User ' /etc/httpd/conf/httpd.conf`/User nobody/g" /etc/httpd/conf/httpd.conf \
  && sed -i "s/`grep '^Group ' /etc/httpd/conf/httpd.conf`/Group nobody/g" /etc/httpd/conf/httpd.conf \
  && sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/g' /etc/httpd/conf/httpd.conf

##### Apache PHP 연동 설정
RUN sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php/g' /etc/httpd/conf/httpd.conf \
  && sed -i 's,\(IfModule mime_module.*\),\1\n\tAddType application/x-httpd-php .htm .html .php .inc,g;' /etc/httpd/conf/httpd.conf \
  && sed -i 's,\(IfModule mime_module.*\),\1\n\tAddType application/x-httpd-php-source .phps,g;' /etc/httpd/conf/httpd.conf

##### Apache PHP 버전 숨기기
RUN sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini \
  && echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf \
  && echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

##### phpinfo.php 페이지 생성
RUN curl -s ifconfig.io > /var/www/html/index.html \
  && echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# ADD entry-point.sh /entry-point.sh
# RUN chmod 755 /entry-point.sh
# ENTRYPOINT ["/bin/bash", "/entry-point.sh"]
