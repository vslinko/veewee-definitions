apt-get -y install nginx php5-apc php5-cli php5-curl php5-fpm php5-gd php5-intl php5-mcrypt php5-pgsql php5-sqlite php5-xdebug postgresql

cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes 1;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    server_tokens off;
    server_name_in_redirect off;

    include mime.types;
    default_type application/octet-stream;

    log_format clementine '\$connection \$msec \$request_time \$remote_addr \$request_method \$scheme \$host \$request_uri \$status \$request_length \$bytes_sent';
    access_log /var/log/nginx/access.log clementine;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable msie6;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    server {
        root /vagrant/web;

        location / {
            location ~ \.php$ {
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            }

            try_files \$uri @backend;
        }

        location @backend {
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root/app_dev.php;
        }
    }
}
EOF

cat << EOF > /etc/php5/conf.d/00-php.ini
date.timezone = Europe/Moscow
EOF

cat << EOF > /etc/php5/fpm/php-fpm.conf
[global]
pid = /var/run/php5-fpm.pid
error_log = /var/log/php5-fpm.log

[vagrant]
listen = /var/run/php5-fpm.sock
user = vagrant
group = vagrant
pm = dynamic
pm.max_children = 32
pm.start_servers = 8
pm.min_spare_servers = 4
pm.max_spare_servers = 16
pm.max_requests = 1024
EOF

cat << EOF > /etc/postgresql/8.4/main/pg_hba.conf
local	all	all			trust
host	all	all	0.0.0.0/0	trust
EOF

sed -i'' -e"s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/8.4/main/postgresql.conf

service nginx restart
service php5-fpm restart
service postgresql restart
