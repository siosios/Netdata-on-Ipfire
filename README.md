# Netdata-on-Ipfire

Build scripts for [IPFire](https://www.ipfire.org/) to create a [Netdata](https://www.netdata.cloud/) package (_thanks to [ummeegge](https://community.ipfire.org/u/ummeegge) - the original creator_)

## Content <!-- omit from toc -->

* [Netdata-on-Ipfire](#netdata-on-ipfire)
  * [Install / Update](#install--update)
  * [Build](#build)
  * [Side note](#side-note)
  * [Author](#author)

## Install / Update

Simply run the following commands:

* For IPFire core 172:

  ```console
  # cd /opt/pakfire/tmp
  # wget https://github.com/siosios/Netdata-on-Ipfire/raw/main/core%20172/netdata-1.38.1-1.ipfire
  # tar xvf netdata-1.38.1-1.ipfire
  # ./install.sh
  ```

* For IPFire core 173:

  ```console
  # cd /opt/pakfire/tmp
  # wget https://github.com/siosios/Netdata-on-Ipfire/raw/main/core%20173/netdata-1.38.1-1.ipfire
  # tar xvf netdata-1.38.1-1.ipfire
  # ./install.sh
  ```

To update your existing installation, simply run the __`update.sh`__ script instead of `install.sh`.

## Build

1. First setup your build enviroment per the instructions at https://wiki.ipfire.org/devel/ipfire-2-x/build-howto, you should end up with a folder called ipfire-2.x
2. Next install Dnsmasq onto the system you loaded your build enviroment onto ( if needed ).
3. Then place the files from this repository into the folders withing the ipfire-2.x folder. here is a tutorial for building packages https://wiki.ipfire.org/devel/ipfire-2-x/addon-howto

    ![makesh](https://user-images.githubusercontent.com/135543/153519689-1e02c1aa-c82e-45ce-994a-9993a288535a.png)

After you add `lfsmake2 netdata` to the `make.sh` file as the last line of the `buildipfire() {}` block, you can then run `make.sh` script to build all the packages and ipfire, this will take some time so go eat dinner.

> I suggest reading the how to build an addon from this point and then continue reading.

Once finished, you should get a complete build with no errors and you'll find the `netdata-[version].ipfire` package in `/ipfire-2.x/packages/` folder.

From there you can upload and install the package on your ipfire machine.

All files will be installed in the `/opt/netdata` folder except `logrotate` and the netdata `init.d` script.

> The reason for opt was the normal install was wreaking havoc on the file system and would not install properly and sometimes not finish the build proccess due to tar errors.

__The internal update won't work since you can't compile it, Ipfire does not have the tools installed to do it.__

## Side note

I worked on this as a learning experience, my first attempts were manual builds in the shell and then run the build proccess to create the ipfire package.

Enjoy!

## Author

* [siosios](https://community.ipfire.org/u/siosios)