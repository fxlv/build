#!/bin/bash
#
# Download and build git
#

if [ "$OSTYPE" == "darwin15" ]; then
    echo "Running on OSX"
    echo "You need to have your build dependencies installed manually"
elif [ "$OSTYPE" == "linux-gnu" ]; then
    echo "Running on Linux"
    sudo apt-get -y install build-essential autoconf zlib1g-dev libcurl4-openssl-dev
else
    echo "This is not a supported OS. Perhaps some BSD? Will use linux settings."
fi

echo "Cloning..."
git clone git@github.com:git/git.git
cd git
echo "Configuring..."
make configure
time ./configure --prefix="${HOME}"/opt --without-tcltk --with-curl | tee configure.log
echo "Building..."
make -j2
echo "Installing..."
make install
