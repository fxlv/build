#!/bin/bash
#
# dependencies: build-essential libssl-dev libcurl4-openssl-dev
#


# nrpe requires libssl and at least on ARM Debian the configure script cannot find it by itself
# so we have to find it for it

libssl_path=$(dirname $(dpkg -L libssl-dev | grep libssl.so))

curl -L -OO nrpe.tar.gz http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
md5=$(md5sum nrpe-2.15.tar.gz|cut -f 1 -d " ")
if [ $md5 == "3921ddc598312983f604541784b35a50" ]; then
	echo "Checksum OK"
	tar xvzf nrpe-2.15.tar.gz
	cd nrpe-2.15
	time ./configure --enable-command-args --with-ssl-lib=$libssl_path |tee configure.log
	time make | tee make.log
	if [ -e src/nrpe ]; then
		echo
		echo
		echo "Looks like everything went well"
		echo "nrpe binary is in src/ now"
		echo "You can test it out by running:"
		echo "./nrpe -c /etc/nagios/nrpe.cfg -d -4"
		echo
	else
		echo "Looks like something failed, check the logs."
	fi
else
	echo "Checksum verification failed"
fi


