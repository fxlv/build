#!/bin/bash
#
# Download and build statically linked tmux binary
#

if [ "$OSTYPE" == "darwin15" ]; then
    md5sum="md5"
    md5summ_field=4 # osx
    echo "Running on OSX"
    echo "You need to have your build dependencies installed manually"
elif [ "$OSTYPE" == "linux-gnu" ]; then
    md5summ_field=1 # linux
    md5sum="md5sum"
    echo "Running on Linux"
    sudo apt-get -y install build-essential bzip2 curl libncurses5-dev bc
else
    echo "This is not a supported OS. Perhaps some BSD? Will use linux settings."
    md5summ_field=1 # linux
    md5sum="md5sum"
fi

libevent="libevent-2.0.22"
tmux="tmux-2.1"

libevent_dir="${libevent}-stable"

libevent_tarball="${libevent}-stable.tar.gz"
tmux_tarball="${tmux}.tar.gz"

expected_md5_libevent="c4c56f986aa985677ca1db89630a2e11"
expected_md5_tmux="74a2855695bccb51b6e301383ad4818c"

echo "Libevent tarball $libevent_tarball"
if [ ! -e $libevent_tarball ]; then
    curl -L -O "https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/${libevent_tarball}"
else
    echo "Libevent tarball already present"
fi
if [ ! -e $tmux_tarball ]; then
    curl -L -O "https://github.com/tmux/tmux/releases/download/2.1/${tmux_tarball}"
else
    echo "Tmux tarball already present"
fi

function get_md5sum()
{
    echo $($md5sum ${1} | cut -f $md5summ_field -d " ")
}

md5_libevent=$(get_md5sum $libevent_tarball)
md5_tmux=$(get_md5sum $tmux_tarball)


if [ "$expected_md5_libevent" != "$md5_libevent" ]; then
    echo "Libevent tarball checksum mismatch"
    exit 1
else
    echo "Libevent checksum OK"
fi

if [ "$expected_md5_tmux" != "$md5_tmux" ]; then
    echo "Tmux tarball checksum mismatch"
    exit 1
else
    echo "Tmux checksum OK"
fi

tar xvzf $libevent_tarball 
cd $libevent_dir
echo "Configuring libevent"
time ./configure --prefix=/opt/libevent | tee configure.log
echo "Building libevent"
time make | tee make.log
time sudo make install | tee make_install.log
echo "Libevent built and installed"

# change back to build directory
cd ..

tar xvzf $tmux_tarball
cd $tmux
echo "Configuring tmux"
CPPFLAGS="-L/opt/libevent/lib -I/opt/libevent/include" LDFLAGS="-L/opt/libevent/lib -I/opt/libevent/include" ./configure --enable-static | tee configure.log
echo "Building tmux"
time make | tee make.log
echo "Tmux built"
# tmux binary now is available here



