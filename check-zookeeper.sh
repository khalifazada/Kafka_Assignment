#!/bin/bash

test_zk() {
	jps | grep QuorumPeerMain
}

ZK=$(test_zk)

run_zk() {
    zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties
}

if [[ $ZK != *QuorumPeerMain* ]]
then
	echo -e "*** ZOOKEEPER NOT RUNNING\n*** START ZOOKEEPER?" 
	read USER_INPUT

	if [[ "$USER_INPUT" == "yes" || "$USER_INPUT" == "y" ]]
	then	
		echo -e "*** STARTING ZOOKEEPER SERVER"
		run_zk
		exit 0
	else
		echo -e "*** INCORRECT INPUT, EXITING..."
		exit 1
	fi
else
	echo -e "*** ZOOKEEPER SERVER RUNNING\n*** $(echo $ZK)"
	exit 0
fi
