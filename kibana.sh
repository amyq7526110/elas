
kibana=/opt/kibana/config

cd $kibana

sed -i '/# server.port/s/# //' kibana.yml 
sed -i '/^# server.host/s/# //' kibana.yml 
sed -i '/url:/s/# //;/url:/s/localhost/es1/' kibana.yml 
sed -i '/^# kibana.index/s/# //' kibana.yml 
sed -i '/AppId/s/# //' kibana.yml 
sed -i '/Timeout:/s/# //' kibana.yml 
sed -i '/shardTimeout:/s/^/# /' kibana.yml
