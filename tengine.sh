#!/bin/bash
    yum update -y
    yum install epel-release -y
    yum install gcc gcc-c++ autoconf automake -y
    yum install pcre-devel -y
    yum install openssl-devel -y
    yum install libmcrypt libmcrypt-devel mcrypt mhash -y
	yum install kernel-headers kernel-devel make -y
	rm -rf /usr/local/nginx
	cd /root
	wget http://tengine.taobao.org/download/tengine-2.3.3.tar.gz
	tar zxvf tengine-2.3.3.tar.gz
	cd /root/tengine*
	./configure --without-http_upstream_keepalive_module --with-stream --with-stream_ssl_module --with-stream_sni --add-module=modules/ngx_http_upstream_* --add-module=modules/ngx_debug_* --add-module=modules/ngx_http_slice_module --add-module=modules/ngx_http_user_agent_module --add-module=modules/ngx_http_reqstat_module --add-module=modules/ngx_http_proxy_connect_module --add-module=modules/ngx_http_footer_filter_module
    make
    make install
	echo "proxy_http_version 1.1;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection \"upgrade\";
proxy_redirect off;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#proxy_read_timeout 30s;    # 连接超时时间" >/usr/local/nginx/ws
    echo "#user  nobody;
worker_processes auto;
worker_rlimit_nofile 51200;
#pid        logs/nginx.pid;
events
    {
        use epoll;
        worker_connections 51200;
        multi_accept on;
    }
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    check_shm_size 50m;
    #vmess-ws
    include /usr/local/nginx/*.conf;
}
" >/usr/local/nginx/conf/nginx.conf
	echo "[Unit]
Description=The nginx HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target
 
[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
 
[Install]
WantedBy=multi-user.target" >/lib/systemd/system/nginx.service
        systemctl daemon-reload
        systemctl start nginx
        systemctl enable nginx
        echo -e "安装完成"
