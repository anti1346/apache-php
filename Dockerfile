FROM centos:7

##### 시스템 운영에 필요한 패키지 설치
RUN yum install -y epel-release yum-utils
#RUN yum install -y tar unzip vi vim telnet net-tools curl openssl

##### Apache 설치
RUN yum install -y httpd httpd-tools

##### PHP 설치
RUN yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum-config-manager --enable remi-php74
RUN yum install -y php php-cli php-common php-devel php-json php-mbstring php-pdo php-gd php-xml php-mcrypt \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && rm -rf /tmp/*

##### Apache 유저, 그룹, 기본설정(ServerName)
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

##### 운영체제 업데이트 및 yum cache 삭제
# RUN yum update -y  \
#   && yum clean all \
#   && rm -rf /var/cache/yum \
#   && rm -rf /tmp/*

WORKDIR /var/www/html

ADD phpinfo.php /var/www/html/

EXPOSE 80

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# ADD entry-point.sh /entry-point.sh
# RUN chmod 755 /entry-point.sh
# ENTRYPOINT ["/bin/bash", "/entry-point.sh"]