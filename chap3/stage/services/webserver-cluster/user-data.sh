#!/bin/bash
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB Address: ${db_address}</p>
<p>DB Port: ${db_port}</p>
EOF

yum -y install busybox
nohup busybox httpd -f -p "${server_port}" &

