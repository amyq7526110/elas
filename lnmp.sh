#!/bin/bash
mylnmp(){
ln=lnmp_soft.tar.gz
ng=nginx-1.12.2.tar.gz
[ ! -f $ln ]&& echo "没有lnmp_soft.tar.gz" && exit
yum -y install gcc openssl-devel pcre-devel 
yum -y install mariadb-server mariadb mariadb-devel 
yum -y install php php-mysql 
tar -xf $ln 
cd  lnmp_soft/ 
yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm  
[ ! -f $ng ]&& echo "没有nginx-1.12.2.tar.gz" && exit  
tar -xf $ng  
cd   nginx-1.12.2/  
sed -i  '49s/nginx/Apache/'  src/http/ngx_http_header_filter_module.c
sed -i  '50s/: /: Apache/;50s/NGINX_VER//'  src/http/ngx_http_header_filter_module.c
sed -i  '51s/: /: Apache/;51s/NGINX_VER_BUILD//'  src/http/ngx_http_header_filter_module.c 
sed  -ri  '13,14s#"(.*)"#"Apache"#'  src/core/nginx.h
sed -i  '36s/nginx/Apache/' src/http/ngx_http_special_response.c
./configure --with-http_ssl_module --with-stream --with-http_stub_status_module --without-http_autoindex_module --without-http_ssi_module
make && make install  
ln -s /usr/local/nginx/sbin/nginx /sbin
systemctl restart mariadb
systemctl enable mariadb
systemctl restart php-fpm.service
systemctl enable php-fpm
cp /root/lnmp_soft/php_scripts/mysql.php /usr/local/nginx/html/
sed  -i   '65,71s/^.*#/        /'  /usr/local/nginx/conf/nginx.conf
sed  -i   '70s/_.*$/.conf;/' /usr/local/nginx/conf/nginx.conf
sed  -i   '69d'   /usr/local/nginx/conf/nginx.conf
nginx
firefox 127.0.0.1/mysql.php
}
mylnmp
