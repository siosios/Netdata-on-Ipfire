# Netdata-on-Ipfire
Build scripts for Ipfire to create a Netdata package (thanks to ipfire and ummeegge - the original creator)


First setup your build enviroment per the instructions at https://wiki.ipfire.org/devel/ipfire-2-x/build-howto, you should end up with a folder called ipfire-2.x

Next install Dnsmasq onto the system you loaded your build enviroment onto.

Then place the files from this repository into the folders withing the ipfire-2.x folder. here is a tutorial for building packages https://wiki.ipfire.org/devel/ipfire-2-x/addon-howto

you can then run make.sh build to build all the packages and ipfire, this will take some time so go eat dinner.

you should come back to a complete build with no errors and you'll find the netdata-1.33.0-1.ipfire package in /ipfire-2.x/packages/

from there you can upload and install on your ipfire machine

All files will be in /opt/netdata except logrotate and the netdata init.d script, the reason for opt was the normal install was wreaking havic on the file system and would not install properly and sometimes finish the build proccess due to tar errors


I worked on this as a learning experiance, my first attempts were manual builds in the shell and then run the build proccess to create the ipfire package.



enjoy


ps: you can update the url and md5sum in the lfs/netdata file to a newer package and rebuild to keep up to date
