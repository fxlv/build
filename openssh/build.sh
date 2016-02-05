#!/bin/bash
#
#


curl -O http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.3.2.tar.gz
curl -O http://ftp.aso.ee/pub/OpenBSD/OpenSSH/portable/openssh-7.1p2.tar.gz

md5_libressl=$(md5sum libressl-2.3.2.tar.gz | cut -f 1 -d " ")
md5_openssh=$(md5sum openssh-7.1p2.tar.gz | cut -f 1 -d " ")

sudo id

if [ "$md5_libressl" == "35d5bf0fc1bc88d67cfdfa0f00434268" ]; then
	echo "Checksum OK"
	tar xvzf libressl-2.3.2.tar.gz
	cd libressl-2.3.2
    echo "Configuring libressl"
    time ./configure --prefix=/opt/libressl | tee configure.log
    echo "Building libressl"
    time make | tee make.log
    time sudo make install | tee make_install.log
    echo "Libressl installed to /opt/libressl"
else
	echo "Checksum verification failed"
fi

cd ..


if [ "$md5_openssh" == "4d8547670e2a220d5ef805ad9e47acf2" ]; then
	echo "Checksum OK"
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
else
	echo "Checksum verification failed"
fi


