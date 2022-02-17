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
#stop_service ${NAME}
#make_backup ${NAME}
#remove_files

NAME="netdata"

# Stop service
/etc/init.d/${NAME} stop

# Delete old symlink if presant
rm -rfv /etc/rc.d/rc?.d/???${NAME};

if grep -q "${NAME}" /etc/passwd; then
	userdel ${NAME};
	groupdel ${NAME};
	echo "Have deleted group and user '${NAME}'... ";
fi

# Remove all files
rm -rfv \
/opt/netdata/etc/netdata \
/opt/netdata/etc/logrotate.d/netdata \
/opt/netdata/etc/rc.d/init.d/netdata \
/opt/netdata/usr/libexec/netdata \
/opt/netdata/usr/share/netdata \
/opt/netdata/usr/sbin/netdata* \
/opt/netdata/var/cache/netdata \
/opt/netdata/var/lib/netdata \
/opt/netdata/var/log/netdata \
/opt/netdata/var/cache/netdata

# EOF

