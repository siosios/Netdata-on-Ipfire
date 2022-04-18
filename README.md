# Netdata-on-Ipfire
Build scripts for Ipfire to create a Netdata package (thanks to ummeegge - the original creator)


First setup your build enviroment per the instructions at https://wiki.ipfire.org/devel/ipfire-2-x/build-howto, you should end up with a folder called ipfire-2.x

Next install Dnsmasq onto the system you loaded your build enviroment onto.

Then place the files from this repository into the folders withing the ipfire-2.x folder. here is a tutorial for building packages https://wiki.ipfire.org/devel/ipfire-2-x/addon-howto


![makesh](https://user-images.githubusercontent.com/135543/153519689-1e02c1aa-c82e-45ce-994a-9993a288535a.png)


After you add 'lfsmake2 netdata' to the make.sh file as the last line of the buildipfire() {, you can then run make.sh build to build all the packages and ipfire, this will take some time so go eat dinner.

I suggest reading the how to build an addon from this point and then continue reading.

you should come back to a complete build with no errors and you'll find the netdata-1.33.0-1.ipfire package in /ipfire-2.x/packages/

from there you can upload and install on your ipfire machine

All files will be in /opt/netdata except logrotate and the netdata init.d script, the reason for opt was the normal install was wreaking havic on the file system and would not install properly and sometimes not finish the build proccess due to tar errors



I worked on this as a learning experiance, my first attempts were manual builds in the shell and then run the build proccess to create the ipfire package.



enjoy


update: downloading netdata directly from github throws an error that i havent figured out yet and ipfire is using BLAKE2 now so b2sum would give you the hash for the netdata tar file.
