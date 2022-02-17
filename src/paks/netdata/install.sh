#!/bin/bash
############################################################################
#                                                                          #
# This file is part of the IPFire Firewall.                                #
#                                                                          #
# IPFire is free software; you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by     #
# the Free Software Foundation; either version 2 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# IPFire is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of           #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
# GNU General Public License for more details.                             #
#                                                                          #
# You should have received a copy of the GNU General Public License        #
# along with IPFire; if not, write to the Free Software                    #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA #
#                                                                          #
# Copyright (C) 2007 IPFire-Team <info@ipfire.org>.                        #
#                                                                          #
############################################################################
#
. /opt/pakfire/lib/functions.sh

#restore_backup ${NAME}

NAME="netdata"

# Add user and group for ntopng if not already done
if ! grep -q "${NAME}" /etc/passwd; then
    groupadd ${NAME};
    useradd -g ${NAME} -d /opt/netdata/var/lib/netdata -s /sbin/nologin ${NAME};
    echo;
    echo "Have add user and group '${NAME}'";
else
    echo;
    echo "User already presant leave it as it is";
fi

extract_files

# Set hostname in netdata.conf
HOSTNAME=$(awk -F= '/HOSTNAME/ {print $2}' /var/ipfire/ethernet/settings)
sed -i "s/hostname = .*/hostname = ${HOSTNAME}/" /opt/netdata/etc/netdata/netdata.conf

## Add symlinks
# Possible runlevel ranges
echo;
echo "${Y}Will set symlinks to activate the initscript for start|stop|reboot${N}";
SO="[2-5][0-9]";
SA="[4-7][0-9]";
RE="[2-5][0-9]";
# Search free runlevel
STOP=$(ls /etc/rc.d/rc0.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SO}" | head -1);
START=$(ls /etc/rc.d/rc3.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${SA}" | head -1);
REBOOT=$(ls /etc/rc.d/rc6.d/ | sed -e 's/[^0-9]//g' | awk '$1!=p+1{print p+1" "$1-1}{p=$1}' | sed -e '1d' | tr ' ' '\n' | grep -E "${RE}" | head -1);
## Add symlinks
ln -s ../init.d/${NAME} /etc/rc.d/rc0.d/K${STOP}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc3.d/S${START}${NAME};
ln -s ../init.d/${NAME} /etc/rc.d/rc6.d/K${REBOOT}${NAME};

# Set permissions
chown -R root:netdata /opt/netdata/var/lib/netdata
chown -R netdata:netdata /opt/netdata/var/cache/netdata/
chown -R root:netdata /opt/netdata/usr/lib/netdata/
chown -R netdata:netdata /opt/netdata/usr/share/netdata
chown -R netdata:netdata /opt/netdata/var/log/netdata
chown -R root:netdata /opt/netdata/etc/netdata
chown root:root /opt/netdata/etc/netdata/netdata.conf

# Enable application groups
chown root:netdata /opt/netdata/usr/libexec/netdata/plugins.d/apps.plugin
chmod 4750 /opt/netdata/usr/libexec/netdata/plugins.d/apps.plugin

# Start service
/etc/init.d/${NAME} start

# EOF

