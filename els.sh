#!/bin/bash 
  
   sed -ri  's/^# cluster(.*):(.*)/cluster\1: nsd1806/' /etc/elasticsearch/elasticsearch.yml 

   sed -ri  's/^# (node.name:).*/\1 '$HOSTNAME'/' /etc/elasticsearch/elasticsearch.yml 

   x=`sed -n '/es/p' /etc/hosts | awk '{print $2}'  | xargs | sed 's/^/"/;s/ /","/g;s/$/"/'` 
  sed  -ri '/unicast/s/# (.*):.*/\1: ['$x']/'  /etc/elasticsearch/elasticsearch.yml 
  
  cd /usr/share/elasticsearch/bin/

  ./plugin  install ftp://192.168.1.254/docker/elasticsearch-head-master.zip
  ./plugin  install ftp://192.168.1.254/docker/elasticsearch-kopf-master.zip 
  ./plugin  install ftp://192.168.1.254/docker/bigdesk-master.zip


   

