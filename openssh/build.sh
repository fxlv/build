#!/bin/bash
#
# Download and build Libressl + OpenSSH
# Install only the 'ssh' command to /opt/openssh
#

if [ "$OSTYPE" == "darwin15" ]; then
    md5sum="md5"
    md5summ_field=4 # osx
    echo "Running on OSX"
elif [ "$OSTYPE" == "linux-gnu" ]; then
    md5summ_field=1 # linux
    md5sum="md5sum"
    echo "Running on Linux"
fi

libressl=libressl-2.3.2
openssh=openssh-7.1p2

libressl_tarball="${libressl}.tar.gz"
openssh_tarball="${openssh}.tar.gz"

expected_md5_libressl="35d5bf0fc1bc88d67cfdfa0f00434268"
expected_md5_openssh="4d8547670e2a220d5ef805ad9e47acf2"

if [ ! -e $libressl_tarball ]; then
    curl -O "http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${libressl_tarball}"
else
    echo "Libressl tarball already present"
fi

if [ ! -e $openssh_tarball ]; then
    curl -O "http://ftp.aso.ee/pub/OpenBSD/OpenSSH/portable/${openssh_tarball}"
else
    echo "OpenSSH tarball already present"
fi

md5_libressl=$($md5sum ${libressl_tarball} | cut -f $md5summ_field -d " ")
md5_openssh=$($md5sum ${openssh_tarball} | cut -f $md5summ_field -d " ")


if [ "$expected_md5_libressl" != "$md5_libressl" ]; then
    echo "Libressl tarball checksum mismatch"
    exit 1
else
    echo "Libressl checksum OK"
fi

if [ "$expected_md5_openssh" != "$md5_openssh" ]; then
    echo "OpenSSH tarball checksum mismatch"
    exit 1
else
    echo "OpenSSH checksum OK"
fi

# get sudo to ask for password so that it wouldn't do it later in the process
sudo id

tar xvzf libressl-2.3.2.tar.gz
cd libressl-2.3.2
echo "Configuring libressl"
time ./configure --prefix=/opt/libressl | tee configure.log
echo "Building libressl"
time make | tee make.log
time sudo make install | tee make_install.log
echo "Libressl installed to /opt/libressl"

# change back to build directory
cd ..

tar xvzf openssh-7.1p2.tar.gz
cd openssh-7.1p2
echo "Configuring openssh"
export LD_LIBRARY_PATH=/opt/libressl/lib
./configure --prefix=/opt/openssh --with-ssl-dir=/opt/libressl | tee configure.log
echo "Building openssh"
time make | tee make.log
echo "Installing openssh"
sudo mkdir -p /opt/openssh/bin
sudo cp ./ssh /opt/openssh/bin/
echo "Openssh installed to /opt/openssh" 

if [ -e ./ssh ]; then
    echo
    echo
    echo "Looks like everything went well"
    echo "ssh binary is in src/ now"
    echo "./ssh -V"
    echo
else
    echo "Looks like something failed, check the logs."
fi


