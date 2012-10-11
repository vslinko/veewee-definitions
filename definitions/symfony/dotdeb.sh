curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

cat << EOF > /etc/apt/sources.list.d/dotdeb.list
deb http://packages.dotdeb.org squeeze all
deb-src http://packages.dotdeb.org squeeze all
deb http://packages.dotdeb.org squeeze-php54 all
deb-src http://packages.dotdeb.org squeeze-php54 all
EOF

apt-get update
