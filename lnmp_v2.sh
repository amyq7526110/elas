#!/bin/bash 
mylnmp(){
#       安装 lnmp 环境  
 
#       安装部署 Nginx Mariadb Php Php-fem

#       判断是否有yum 源
  
        yum=`yum repolist  | awk -F:  '/repolist/{print $2}' |  sed 's/ //;s/,//'`       

        [  $yum  -le  0    ] && echo "you don't have  yum " && exit 1


#       安装依赖包               

        yum -y install gcc openssl-devel pcre-devel

        

#

        ln=lnmp_soft.tar.gz
   
        ng=nginx-1.12.2.tar.gz

#       安装  Nginx

        cd ~
     
#       判断家目录文件夹下是否有 lnmp_soft.tar.gz

        [  !  -f  $ln   ] && echo "you don't have lnmp_soft.tar.gz"  && exit 2

#       源码安装  Nginx

        useradd -s /sbin/nologin  nginx 
      
        tar -xf $ln

        cd lnmp_soft/

        yum -y install ./php-fpm-5.4.16-42.el7.x86_64.rpm

        tar -xf $ng

        cd  nginx-1.12.2/

#       修改 服务器名

        newname=Apache
        sed -i  '49s/nginx/Apache/'  src/http/ngx_http_header_filter_module.c
        sed -i  '50s/: /: Apache/;50s/NGINX_VER//'  src/http/ngx_http_header_filter_module.c
        sed -i  '51s/: /: Apache/;51s/NGINX_VER_BUILD//'  src/http/ngx_http_header_filter_module.c
        sed  -ri  '13,14s#"(.*)"#"Apache"#'  src/core/nginx.h
        sed -i  '36s/nginx/Apache/' src/http/ngx_http_special_response.c

#        ./configure 安装模块
   
#        --prefix=/usr/local/nginx       \\ 指定安装路径
#        --user=nginx                    \\ 指定用户
#        --group=nginx                   \\ 指定组
#        --with-http_ssl_module          \\ 开启SSL加密功能
#        --with-stream                   \\ 开启TCP/UDP代理模块
#        --with-http_stub_status_module       \\ 开启status状态页面
#        --without_http_autoindex_module \\ 禁用自动索引文件目录模块
#        --without_http_ssi_module       \\ 禁用ssi模块
 

        ./configure    \
        --prefix=/usr/local/nginx   \
        --user=nginx                \
        --group=nginx               \
        --with-http_ssl_module      \
        --with-stream               \
        --with-http_stub_status_module   \
        --without-http_autoindex_module \
        --without-http_ssi_module 
   
        make && make install 

#       创建 快捷方式   

        ln -s /usr/local/nginx/sbin/nginx /sbin
 

#       安装 mairadb php 环境

        yum -y install mariadb-server mariadb mariadb-devel
        yum -y install php php-mysql


#      修改配置文件
  
       conf="/usr/local/nginx/conf/nginx.conf" 

        sed  -i   '65,71s/^.*#/        /'  $conf
        sed  -i   '70s/_.*$/.conf;/'       $conf
        sed  -i   '69d'                    $conf
        sed -ri '/^ +index/s/index/index       index.php/'  $conf
    

#       启动服务
                 
        systemctl restart mariadb

        systemctl enable mariadb

        systemctl restart php-fpm.service

        systemctl enable php-fpm

        nginx

        echo "/usr/local/nginx/sbin/nginx"  >> /etc/rc.local

        chmod +x /etc/rc.local
#      验证
  
       cp  ../php_scripts/mysql.php  /usr/local/nginx/html/

       sed -ri  '/^\$mysql/s/root(.*)mysql/root\x27,\x27Azsd1234.\x27,\x27mysql/' /usr/local/nginx/html/mysql.php
 
#       firefox 127.0.0.1/mysql.php

}
#      优化

#      优化并发数 
myyh(){
       ngcf="/usr/local/nginx/conf/nginx.conf"

       sed -i  '/worker_connections/s/1024/65535/'   $ngcf

       sed -i '$a  * soft nofile 65535' /etc/security/limits.conf
       sed -i '$a  * hard nofile 65535' /etc/security/limits.conf 

#      增加数据包头部缓存大小 
   
       http_num=`awk '/^http/{print NR}'  $ngcf    `       
 
       let anum=http_num+2

       sed -i ''$anum'a   large_client_header_buffers 4 4k;'    $ngcf

       sed -i ''$anum'a   client_header_buffer_size  1k;'      $ngcf
   
       sed -i  's/^l/    l/'  $ngcf
  
       sed -i  's/^c/    c/'  $ngcf

#      定义对静态页面的缓存时间
 
       ser_num=`awk   '/^ +server /{print NR}'  $ngcf `               
       
       let  snum=ser_num+2

       sed -i ''$snum'a  }'  $ngcf
       sed -i ''$snum'a  expires        30d;'  $ngcf
       sed -i ''$snum'a location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {'  $ngcf

       sed -i  's/^l/        l/'  $ngcf
       sed -i  's/^e/        e/'  $ngcf
       sed -i  's/^}/        }/'  $ngcf

#      定义状态页面
  
       sed -i  ''$snum'a   }' $ngcf
       sed -i  ''$snum'a   stub_status on;' $ngcf
       sed -i  ''$snum'a   location /status {' $ngcf
  
       sed -i  's/^l/        l/'  $ngcf
       sed -i  's/^s/        s/'  $ngcf
       sed -i  's/^}/        }/'  $ngcf

#      对页面进行压缩处理
#      gzip on;                            //开启压缩
#      gzip_min_length 1000;                //小文件不压缩
#      gzip_comp_level 4;                //压缩比率
#      gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
#                                          //对特定文件压缩，类型参考mime.types

        gnum=`awk '/gzip /{print NR}' $ngcf`

        sed  -i  '/gzip/s/#//'  $ngcf

        sed  -i  ''$gnum'a \
    gzip_min_length 1000;  \
    gzip_comp_level 4;             \
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript; '  $ngcf
 

#       服务器内存缓存


        sed  -i ''$anum'a  \
   open_file_cache          max=2000  inactive=20s; \
        open_file_cache_valid    60s; \
        open_file_cache_min_uses 5; \
        open_file_cache_errors   off; '  $ngcf

#    //设置服务器最大缓存2000个文件句柄，关闭20秒内无请求的文件句柄
#    //文件句柄的有效时间是60秒，60秒后过期
#    //只有访问次数超过5次会被缓存
}
proxy(){
conf=/usr/local/nginx/conf/nginx.conf

           echo  "请输入反向代理的地址"       

           read -a  ip

           sed -rie ":begin; /^ +location(.*)php/,/conf;\n/ { /conf;\n/! { $! { N; b begin }; }; s/\n/\n#/g;s/^/#/ };"  $conf

           for i in ${ip[@]}

           do
           server=$server"\n    server ${i}:80;"

           done


           sed  -i   "/^http/{n;n;n;s/$/\n    upstream haha{${server}\n    }/}" $conf
#           sed  -i  '/^ +index/{s#$#\n\n            proxy_pass http://haha;#}' /usr/local/nginx/conf/nginx.conf 

           sed  -ri  '/^ +index/{s#$#\n            proxy_set_header Host $http_host;\n            proxy_set_header X-Forward-For $remote_addr;\n            proxy_pass http://haha;#}'  $conf


#             proxy_set_header Host $http_host;
#             proxy_set_header X-Forward-For $remote_addr;
 
#          nginx反向代理：服务器basePath路径问题如何解决
#          
#          比如：访问地址www.xxx.com.cn:20023然后映射到nginx服务器80端口
#          
#          解决方法加“proxy_set_header Host $http_host;proxy_set_header X-Forward-For $remote_addr;”具体如下
#          
#           server { 
#          
#                  listen       80; 
#                  server_name  www.xxx.com.cn; 
#           
#                  location / {
#                       proxy_set_header Host $http_host;
#                       proxy_set_header X-Forward-For $remote_addr;
#                       proxy_pass      http://ip:9081/;
#                  }
#          
#          }
}
redis(){
    # 判断 root 下 是否有 Redis tar包 

    cd ~

    re=redis-4.0.8.tar.gz

    [ ! -f $re ] && echo "没有$re" && exit 1

    #编译安装

    yum -y install gcc

    tar -xf   $re

    cd redis-4.0.8

    make && make  install

    yum -y install expect

      expect <<EOF
      
      spawn  utils/install_server.sh
      
      expect "Please"      {send "\n"}
      expect "Please"      {send "\n"}
      expect "Please"      {send "\n"}
      expect "Please"      {send "\n"}
      expect "Please"      {send "\n"}
      expect "ok"          {send "\n"}
      expect "#"           {send "exit\n"}

EOF

     conf=/etc/redis/6379.conf

#            常用配置选项

#            – port 6379                       //端口
#            – bind 127.0.0.1                  //IP地址
#            – tcp-backlog 511                 //tcp连接总数
#            – timeout 0                       //连接超时时间
#            – tcp-keepalive 300               //长连接时间
#            – daemonize yes                   //守护进程方式运行
#            – databases 16                    //数据库个数
#            – logfile /var/log/redis_6379.log //日志文件
#            – maxclients 10000                //并发连接数量
#            – dir /var/lib/redis/6379         //数据库目录内存管理

#            • 内存清除策略

#            – volatile-lru                //最近最少使用 (针对设置了TTL的key)
#            – allkeys-lru                 //删除最少使用的key
#            – volatile-random             //在设置了TTL的key里随机移除
#            – allkeys-random              //随机移除key
#            – volatile-ttl (minor TTL)    //移除最近过期的key
#            – noeviction                  //不删除,写满时报错内存管理(续1)

#            • 选项默认设置

#            – maxmemory <bytes>           //最大内存
#            – maxmemory-policy noeviction //定义使用策略
#            – maxmemory-samples 5         //个数 (针对lru 和 ttl 策略)


     ip=`ifconfig    | awk '/inet/{print $2}' | head -1`

     port=63${ip##*.}

     sed  -i  '/^bind/s/127.0.0.1/ '$ip'/'  $conf

     sed -i '/^port /s/6379/'${port}'/'   $conf


#       修改脚本

      sed  -ri  '/-p/s/-p(.*)/-h '$ip' -p '$port'  shutdown/' /etc/init.d/redis_6379

#     sed -ri '/REDISPORT/s/6379/6345/' /etc/init.d/redis_6379       a

      ln -n /etc/init.d/redis_6379  /bin/
#       重新启动

     /etc/init.d/redis_6379  stop

     /etc/init.d/redis_6379  start
 

}
phpredis(){

#  配置php支持Redis  


#   • 安装php扩展
  
          cd ~

          yum -y install autoconf automake
      
          yum -y install ./php-devel-5.4.16-42.el7.x86_64.rpm

#     
       php_re=php-redis-2.2.4.tar.gz

       tar -xf  $php_re
 
       cd  phpredis-2.2.4/
  
       /usr/bin/phpize

       ./configure --with-php-config=/usr/bin/php-config

       make && make install  
       
       sed  -ri  '/^\; extension/s/\; //'  /etc/php.ini   

       sed  -ri '/"ext"/s/_dir(.*)/ = "redis.so"/' /etc/php.ini

       sed  -ri '/^extension_dir/s/=(.*)/= "\/usr\/lib64\/php\/modules\/"/' /etc/php.ini
       systemctl restart php-fpm
    
#     部署测试页面

     ip=`ifconfig    | awk '/inet/{print $2}' | head -1`

     port=63${ip##*.}

echo "<?php
\$redis = new redis();
\$redis->connect('$ip','$port');
\$redis->set('school','tarena');
echo \$redis->get('school');
?>"  >>  /usr/local/nginx/html/redis.php

    firefox 127.0.0.1/redis.php


  


}

mylnmp
myyh
#proxy
#redis
#phpredis
nginx -s reload
