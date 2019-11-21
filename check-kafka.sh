#!/bin/bash

# custom function - executes server i
run_kafka() {
    $KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server-$1.properties
}

# custom function - number of Kafka servers running
test_kafka() {
	jps | grep Kafka | wc -l
}

KF=$(test_kafka)

# custom function - start
start_process() {
	read USER_INPUT
	if [[  " ${N[*]} " = *" $USER_INPUT "* ]]
	then
		run_kafka $USER_INPUT	
	else
		echo -e "*** INCORRECT INPUT, EXITING..."
	fi
}

# number of servers that can be started
N=(1 2 3)
if [[ $KF == 0 ]]
then
	echo -e "*** NO KAFKA SERVERS RUNNING" 
	./check-zookeeper.sh
	echo -e "*** SPECIFY NUM OF KAFKA SERVERS TO START (1-3)"
	read USER_INPUT
	if [[  " ${N[*]} " = *" $USER_INPUT "* ]]
	then
		for i in $( eval echo {1..$USER_INPUT} )
		do
			run_kafka $i
		done
		RUN_SERVERS=$(jps | grep Kafka)
		echo -e "*** $test_kafka KAFKA SERVER(S) RUNNING\n$RUN_SERVERS"	
	else
		echo -e "*** INCORRECT INPUT, EXITING..."
	fi
else
	echo -e "*** $KF SERVER(S) RUNNING"
	ACTIVE_BROKERS=$(zookeeper-shell.sh localhost:2181 ls /brokers/ids | tail -1)
	echo -e "*** ACTIVE BROKER IDS $ACTIVE_BROKERS"
	echo -e "*** $[3-$KF] SERVER(S) CAN BE STARTED"
	
	for i in {1..3}
	do
		if echo "$ACTIVE_BROKERS" | grep -q "$i"
		then
			continue
		else
			echo "*** ENTER $i AS BROKER ID TO START"
			start_process
			echo -e $(jps | grep Kafka)
		fi
	done
	
fi
