FROM ubuntu:18.04
RUN mkdir /usr/src/plugin
WORKDIR /usr/src/plugin

# Grabbing toolchain stuff
RUN apt-get update
RUN apt-get install -y wget gpg curl libarchive13 xz-utils pkg-config make git cmake  p7zip p7zip-full  zlib1g
RUN wget https://github.com/devkitPro/pacman/releases/download/v1.0.2/devkitpro-pacman.amd64.deb -O /tmp/devkitpro-pacman.deb
RUN dpkg -i /tmp/devkitpro-pacman.deb
RUN ln -sf /proc/self/mounts /etc/mtab
RUN dkp-pacman -Syu devkitPPC --needed --noconfirm
RUN dkp-pacman -Syu devkitARM --needed --noconfirm
RUN dkp-pacman -Syu general-tools --needed --noconfirm
RUN apt-get install -y vim

# Configuring environment variables
ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=/opt/devkitpro/devkitARM
ENV DEVKITPPC=/opt/devkitpro/devkitPPC

# Grabbing dependencies
RUN dkp-pacman -Syu devkitPPC wut-tools wut --noconfirm
ENV WUT_ROOT=/opt/devkitpro/wut

WORKDIR /tmp
RUN git clone --recursive --single-branch --branch wut https://github.com/Maschell/libutils.git
WORKDIR /tmp/libutils
RUN mkdir build
WORKDIR /tmp/libutils/build
RUN cmake -DCMAKE_TOOLCHAIN_FILE=$WUT_ROOT/share/wut.toolchain.cmake -DCMAKE_INSTALL_PREFIX=$WUT_ROOT ../
RUN make install

# Grabbing WiiUPluginSystem
WORKDIR /tmp
RUN git clone --recursive https://github.com/wiiu-env/WiiUPluginSystem.git
WORKDIR /tmp/WiiUPluginSystem
RUN make
RUN make install

# Grabbing libs
RUN wget https://raw.githubusercontent.com/Maschell/WiiUPluginLoader/master/installupdateportlibs.sh -O /tmp/installupdateportlibs.sh
RUN chmod +x /tmp/installupdateportlibs.sh
WORKDIR /tmp
RUN ./installupdateportlibs.sh


# Configuring for building
WORKDIR /usr/src/plugin


