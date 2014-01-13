Scripts for using low-level discovery of JBoss items in Zabbix
==============================================================

These scripts are intended to be used with the Zabbix agent, to enable low-level discovery of JBoss items like queues or message pools. 

Requirements
-----------

* Functional Zabbix server and agent
* Functional and running JBoss server
* Authentication information for JBoss JMX console
* Perl

These scripts are tested on the following versions:
	
* RHEL/CentOS 6.5
* Zabbix 2.2.1
* JBoss EAP 5.2.0

Quick setup
===========

1.	Copy the contents of this repository in /opt/zabbix.
2.	Modify /opt/zabbix/twiddle.properties with the correct information for your environment.
3.	Locate the twiddle.sh script wich is part of the JBoss software.
4.	Modify the $_twiddle parameter under #Options in the queryJBoss.pl script with the output of step 3.

You should be good to go now, you can test this by running the script from the commandline first:

	/opt/zabbix/queryJBoss.pl jboss.messaging.destination QUEUE

This should return all JBoss queue's that are present in your JBoss environment:

	"data":[

	{
		"{#QUEUE_JNDI}":"jboss.messaging.destination:service=Queue,name=DLQ",
		"{#QUEUE_SERVICE}":"Queue",
		"{#QUEUE_NAME}":"DLQ",
	}
	,
	{
		"{#QUEUE_JNDI}":"jboss.messaging.destination:service=Queue,name=ExpiryQueue",
		"{#QUEUE_SERVICE}":"Queue",
		"{#QUEUE_NAME}":"ExpiryQueue",
	}	

If this is working, you can add the script to the zabbix_agentd.conf:

	UserParameter=jboss.queue.discovery,/opt/zabbix/queryJBoss.pl jboss.messaging.destination QUEUE

Now in Zabbix it's possible to configure low-level discovery of all these queues using the "jboss.queue.discovery" key and the QUEUE_JNDI, QUEUE_SERVICE and QUEUE_NAME macros.

Remeber this is just an example using queues. The script handles all output from JBoss dynamically, so it's not really limited by anything. You can query all things you can see in the JBoss jmx-console.

More information
================

I'm in the progress of setting up a blogpost explaining this in detail. If you need a hand now in setting this up, please send me a message!
