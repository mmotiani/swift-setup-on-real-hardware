#! /bin/bash        
	sudo apt-get update
	sudo apt-get install curl gcc memcached rsync sqlite3 xfsprogs \
	                     git-core libffi-dev python-setuptools \
	                     liberasurecode-dev libssl-dev
	sudo apt-get install python-coverage python-dev python-nose \
	                     python-xattr python-eventlet \
	                     python-greenlet python-pastedeploy \
	                     python-netifaces python-pip python-dnspython \
	                     python-mock
	sudo mkfs.xfs -f /dev/sda1
	sudo mkfs.xfs -f /dev/sdb1
	sudo mkfs.xfs -f /dev/sdc1
	sudo mkfs.xfs -f /dev/sdd1
	sudo mkfs.xfs -f /dev/sdd2
	cp /etc/fstab /etc/fstab.insert.bak
	cat >> /etc/fstab << EOF
	/dev/sda1 /mnt/sda1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
	/dev/sdb1 /mnt/sdb1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
	/dev/sdc1 /mnt/sdc1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
	/dev/sdd1 /mnt/sdd1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
	/dev/sdd2 /mnt/sdd2 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
	EOF
	sudo mkdir /mnt/sda1
	sudo mkdir /mnt/sdb1
	sudo mkdir /mnt/sdc1
	sudo mkdir /mnt/sdd1
	sudo mkdir /mnt/sdd2
	sudo mount /mnt/sda1
	sudo mount /mnt/sdb1
	sudo mount /mnt/sdc1
	sudo mount /mnt/sdd1
	sudo mount /mnt/sdd2
	sudo mkdir /mnt/sda1/1 /mnt/sdb1/2 /mnt/sdc1/3 /mnt/sdd1/4 /mnt/sdd2/5
	sudo chown ${USER}:${USER} /mnt/sda1/1
	sudo chown ${USER}:${USER} /mnt/sdb1/2
	sudo chown ${USER}:${USER} /mnt/sdc1/3
	sudo chown ${USER}:${USER} /mnt/sdd1/4
	sudo chown ${USER}:${USER} /mnt/sdd2/5
	sudo ln -s /mnt/sda1/1 /srv/1
	sudo ln -s /mnt/sdb1/2 /srv/2
	sudo ln -s /mnt/sdc1/3 /srv/3
	sudo ln -s /mnt/sdd1/4 /srv/4
	sudo ln -s /mnt/sdd2/5 /srv/5
	sudo mkdir -p /srv/1/node/sda1
	sudo mkdir -p /srv/2/node/sdb1
	sudo mkdir -p /srv/3/node/sdc1
	sudo mkdir -p /srv/4/node/sdd1
	sudo mkdir -p /srv/5/node/sdd2
	sudo mkdir -p /var/run/swift
	sudo chown -R ${USER}:${USER} /var/run/swift
	for x in {1..5}; do sudo chown -R ${USER}:${USER} /srv/$x/; done
	sudo mkdir -p /var/cache/swift /var/cache/swift2 /var/cache/swift3 /var/cache/swift4
	sudo chown ${USER}:${USER} /var/cache/swift*
	sudo pip install extras
	sudo pip install pytz
	cd $HOME; git clone https://github.com/openstack/python-swiftclient.git
	cd $HOME/python-swiftclient; sudo python setup.py develop; cd -
	git clone https://github.com/openstack/swift.git
	cd $HOME/swift; sudo pip install -r requirements.txt; sudo python setup.py develop; cd -
	cd $HOME/swift; sudo pip install -r test-requirements.txt
	sudo cp $HOME/swift/doc/saio/rsyncd.conf /etc/
	sudo sed -i "s/<your-user-name>/${USER}/" /etc/rsyncd.conf
	sudo rm -rf /etc/rsyncd.conf
	sudo cp /home/swift/rsyncd.conf /etc/
	sudo sed -i "s/RSYNC_ENABLE=false/RSYNC_ENABLE=true/" /etc/default/rsync
	sudo service rsync restart
	rsync rsync://pub@localhost/
	sudo cp $HOME/swift/doc/saio/rsyslog.d/10-swift.conf /etc/rsyslog.d/
	sed -i 's/PrivDropToGroup syslog/PrivDropToGroup adm/g' /etc/rsyslog.conf
	sudo mkdir -p /var/log/swift
	sudo chown -R syslog.adm /var/log/swift
	sudo chmod -R g+w /var/log/swift
	sudo service rsyslog restart
	sudo rm -rf /etc/swift
	cd $HOME/swift/doc; sudo cp -r saio/swift /etc/swift; cd -
	sudo chown -R ${USER}:${USER} /etc/swift
	find /etc/swift/ -name \*.conf | xargs sudo sed -i "s/<your-user-name>/${USER}/"
	sudo sed -i "s/bind_port = 6010/bind_port = 5010/" /etc/swift/object-server/1.conf
	sudo sed -i "s/bind_port = 6020/bind_port = 5020/" /etc/swift/object-server/2.conf
	sudo sed -i "s/bind_port = 6030/bind_port = 5030/" /etc/swift/object-server/3.conf
	sudo sed -i "s/bind_port = 6040/bind_port = 5040/" /etc/swift/object-server/4.conf
	sudo sed -i "s/bind_port = 6012/bind_port = 5012/" /etc/swift/account-server/1.conf
	sudo sed -i "s/bind_port = 6022/bind_port = 5022/" /etc/swift/account-server/2.conf
	sudo sed -i "s/bind_port = 6032/bind_port = 5032/" /etc/swift/account-server/3.conf
	sudo sed -i "s/bind_port = 6042/bind_port = 5042/" /etc/swift/account-server/4.conf
	sudo sed -i "s/bind_port = 6011/bind_port = 5011/" /etc/swift/container-server/1.conf
	sudo sed -i "s/bind_port = 6021/bind_port = 5021/" /etc/swift/container-server/2.conf
	sudo sed -i "s/bind_port = 6031/bind_port = 5031/" /etc/swift/container-server/3.conf
	sudo sed -i "s/bind_port = 6041/bind_port = 5041/" /etc/swift/container-server/4.conf
	sudo mkdir /etc/tmp
	sudo cp /etc/swift/account-server/4.conf /etc/tmp/
	sudo cp /etc/swift/container-server/4.conf /etc/tmp/
	sudo cp /etc/swift/object-server/4.conf /etc/tmp/
	mkdir -p $HOME/bin
	cd $HOME/swift/doc; sudo cp saio/bin/* $HOME/bin; cd -
	sudo chmod +x $HOME/bin/*
	sudo cp $HOME/swift/test/sample.conf /etc/swift/test.conf
	sudo rm -rf /home/swift/bin/remakerings
	sudo rm -rf /home/swift/bin/resetswift
	sudo rm -rf /etc/swift/swift.conf
	sudo cp /home/swift/remakerings /home/swift/bin/
	sudo cp /home/swift/resetswift /home/swift/bin/
	sudo cp /home/swift/swift.conf /etc/swift/
	sudo cp openrc /home/swift/
	echo "export SWIFT_TEST_CONFIG_FILE=/etc/swift/test.conf" >> $HOME/.bashrc
	echo "export PATH=${PATH}:$HOME/bin" >> $HOME/.bashrc
	. $HOME/.bashrc
	remakerings
	$HOME/swift/.unittests
	startmain
	source openrc
	$HOME/swift/.functests
