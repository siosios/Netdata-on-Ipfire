#!/bin/bash -

#
# Nginx configuration script for proxying Netdata
# With ECC crypto and login credentials
#
# ummeegge 24.04.2020
#################################################
#

# Paths
NGINX_CONF="/etc/nginx/nginx.conf"

# Investigate green0 IP since Nginx should only listen there
GREEN_IP=$(awk -F'=' '/GREEN_ADDRESS/ { print $2 }' /var/ipfire/ethernet/settings)

# Formatting Colors and text
COLUMNS="$(tput cols)"
R=$(tput setaf 1)
B=$(tput setaf 6)
b=$(tput bold)
N=$(tput sgr0)
seperator(){ printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -; }
WELCOME="Welcome to 'Nginx as forward proxy for Netdata' integration helper"
WELCOMEA="This script includes ECC crypto and user login integration for Nginx"
START="To start press ${B}${b}'s'${N} and [ENTER]"
QUIT="To quit press ${B}${b}'q'${N} and [ENTER]"

while true
do
	# Choose which routine is wanted
	echo ${N}
	clear
	seperator
	printf "%*s\n" $(((${#WELCOME}+COLUMNS)/2)) "${WELCOME}"
	printf "%*s\n" $(((${#WELCOMEA}+COLUMNS)/2)) "${WELCOMEA}"
	seperator
	echo
	printf "%*s\n" $(((${#START}+COLUMNS)/2)) "${START}";
	printf "%*s\n" $(((${#QUIT}+COLUMNS)/2)) "${QUIT}";
	echo
	seperator
	echo
	read what
	clear

	case "$what" in
		s*|S*)
			## Check if Nginx is is already forwarding proxy for Netdata
			if grep -q 'netdata' /etc/nginx/nginx.conf >/dev/null 2>&1; then
				echo -e "${B}Nginx is already configured as forward proxy for Netdata. Will quit... "
				exit 0
			fi


			## Check for needed software
			# Check if Netdata is installed and running otherwise quit script
			if ! pgrep netdata >/dev/null 2>&1; then
				echo -e "${R}Netdata is not running or may not installed. Need to quit... ${N}"
				exit 1
			fi

			# Check if Nginx is installed
			if ! command -v nginx >/dev/null 2>&1; then
				printf "%b" "${R}Nginx is missing but needed...${N}\n\n${R}Press ${N}${B}'Y'${N}${R} and [ENTER] to install it \nTo skip the installation press ${N}${B}'N'${N}${R} and [ENTER]:${N} "
				read what
				case "$what" in
					y*|Y*)
						/usr/local/bin/pakfire install nginx -y
					;;

					n*|N*)
						exit 1
					;;

					*)
						echo "${R}This option does not exist... ${N}"
						sleep 3
						exit 1
					;;

				esac
			fi

			## Main part
				echo
				echo -e "${R}${b}Set up Nginx web port for Netdata... ${N}"
				echo
				read -p "${B}${b}Please enter a Nginx web port: ${N}" port
				for i in $(netstat -tuln | awk '{ print $4 }' | awk -F':' '{ print $2,$3,$4 }' | tr -d '[:blank:]' | sort -nu); do
				if [ "${port}" -eq "$i" ]; then
				echo "${R}${b}Port blocked... ${N}setting default port 1234"
				port="1234" 
				fi
				done
				
			# Save original configuration
			cp ${NGINX_CONF} ${NGINX_CONF}.orig
			echo -e "${B}Original nginx.conf can be found under /etc/nginx/nginx.conf.orig... ${N}"
			echo
			sleep 3

			## Create ECC CA and DH parameter
			echo -e "${B}Will create an ECC CA and add a ffdhe4096-parameter... ${N}"
			echo
			sleep 3
			mkdir /etc/nginx/ca
			openssl ecparam -out /etc/nginx/ca/server.key -name prime256v1 -genkey
			chmod 600 /etc/nginx/ca/server.key
			openssl req -new -key /etc/nginx/ca/server.key -out /etc/nginx/ca/csr.pem
			openssl req -x509 -days 365 -key /etc/nginx/ca/server.key -in /etc/nginx/ca/csr.pem -out /etc/nginx/ca/certificate.pem
			cat > /etc/nginx/ca/dh.pem << "EOF"
-----BEGIN DH PARAMETERS-----
MIICCAKCAgEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEfz9zeNVs7ZRkDW7w09N75nAI4YbRvydbmyQd62R0mkff3
7lmMsPrBhtkcrv4TCYUTknC0EwyTvEN5RPT9RFLi103TZPLiHnH1S/9croKrnJ32
nuhtK8UiNjoNq8Uhl5sN6todv5pC1cRITgq80Gv6U93vPBsg7j/VnXwl5B0rZp4e
8W5vUsMWTfT7eTDp5OWIV7asfV9C1p9tGHdjzx1VA0AEh/VbpX4xzHpxNciG77Qx
iu1qHgEtnmgyqQdgCpGBMMRtx3j5ca0AOAkpmaMzy4t6Gh25PXFAADwqTs6p+Y0K
zAqCkc3OyX3Pjsm1Wn+IpGtNtahR9EGC4caKAH5eZV9q//////////8CAQI=
-----END DH PARAMETERS-----
EOF

			# Paste new configuration
			cat > ${NGINX_CONF} << "EOF"
worker_processes  1;

events {
	worker_connections  1024;
}


http {
  upstream backend {
	# the netdata server
	server 127.0.0.1:19999;
	keepalive 64;
}

	server {
		listen       GREEN0_IP:port ssl http2; # listen on green0 IP only
		server_name  GREEN0_IP; # green0 IP

  # TLS settings with ECC
		ssl_certificate      /etc/nginx/ca/certificate.pem;
		ssl_certificate_key  /etc/nginx/ca/server.key;
		ssl_protocols TLSv1.3;
		ssl_ciphers TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-CCM:ECDHE-ECDSA-AES256-CCM8:ECDHE-ECDSA-ARIA256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-CCM:ECDHE-ECDSA-AES128-CCM8:ECDHE-ECDSA-ARIA128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ARIA256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ARIA128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-CCM:DHE-RSA-AES256-CCM8:DHE-RSA-ARIA256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-CCM:DHE-RSA-AES128-CCM8:DHE-RSA-ARIA128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384;
		ssl_prefer_server_ciphers   on;

		ssl_dhparam /etc/nginx/ca/dh.pem;
		ssl_ecdh_curve X25519:secp521r1:secp384r1;

		ssl_session_cache    shared:SSL:1m;
		ssl_session_timeout  5m;

		add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; always";
 
	location / {
		auth_basic "Restricted Content";
		auth_basic_user_file /etc/nginx/.htpasswd;

		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://backend;
		proxy_http_version 1.1;
		proxy_pass_request_headers on;
		proxy_set_header Connection "keep-alive";
		proxy_store off;
		}

		# make sure there is a trailing slash at the browser
		# or the URLs will be wrong
		location ~ /netdata/(?<behost>.*) {
		return 301 /netdata/$behost/;

		}

	}

}
EOF

			# Check if .htpasswd is there and not empty
			# otherwise create it and add user

			if [ ! -f "/etc/nginx/.htpasswd" ]; then
				echo
				echo -e "Set up now user credentials to login into Netdata... ${N}"
				echo
				read -p "Please enter a username to autenticate to: " user
				sh -c "echo -n "${user}:" > /etc/nginx/.htpasswd"
				sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
			fi


			# Nginx listens only on green0 interface
			sed -i "s/GREEN0_IP/${GREEN_IP}/g" ${NGINX_CONF}
			if [ ! -z "${port}" ]; then
			sed -i "s/port/${port}/g" ${NGINX_CONF}
			fi
			# Change Netdata´s init script to listen on localhost for nginx proxy instead of green0
			sed -i -e 's/WEBIP=\$/#WEBIP=\$/' -e 's/#WEBIP="/WEBIP="/' /etc/rc.d/init.d/netdata

			# Restart Nginx and check status
			echo
			echo -e "${B}Will restart now Netdata since the configuration has been changed... ${N}"
			echo
			/etc/init.d/netdata restart
			if pgrep netdata >/dev/null 2>&1; then
				echo -e "${B}Congratulations Netdata is running under the following stat... ${N}"
				echo
				netstat -tulpn | grep netdata | grep -v grep
			else
				echo
				echo -e "${R}Something unforssen has happend Netdata is NOT running. Please invest this further... ${N}"
				exit 1
			fi

			# Restart Nginx and check status
			echo
			echo -e "${B}Will restart now Nginx since the configuration has been changed... ${N}"
			/etc/init.d/nginx restart
			if pgrep nginx >/dev/null 2>&1; then
				echo
				echo -e "${B}Congratulations Nginx is running under the following stat... ${N}"
				echo
				netstat -tulpn | grep nginx | grep -v grep
				echo
			else
				echo
				echo -e "${R}Something unforseen has happend Nginx is NOT running. Please invest this further... ${N}"
				exit 1
			fi

			# Finish
			echo
			echo -e "${B}All done :-) --> 'Nginx as forwarding proxy for Netdata' integration helper will be finished now... Goodbye. ${N}"
			echo
			echo -e "${B}${b}You can reach the Netdata Webinterface under the address https://${GREEN_IP}:${port}${N}"
			exit 0
		;;

		q*|Q*)
			echo "Will quit. Goodbye... "
			exit 0
		;;

		*)
			echo "This option does not exist... "
			sleep 3
		;;

	esac
done


# EOF