#!/usr/bin/perl
################################################################################
# queryJBoss.pl - Fetches a list of inventory from JBoss
################################################################################
#
# This script uses the "twiddle.sh" tool to fetch a list of information from
# JBoss.
#
# It takes two arguments: 
#	- the object name filter (i.e. jboss.jca)
#	- OPTIONAL: Zabbix Macro Name
#
# If the optional ZBX_MACRO argument is empty, the script will add the object
# name identifier to the macro name, because this must be unique per template
# in Zabbix.
#
# It is used by the zabbix_agent, which fetches the list and passes it on to 
# Zabbix which in turn creates host items from it using low-level discovery.
#
# Depends on:
#	- the twiddle executable that comes with JBoss
#	- a twiddler.properties file with authentcation information for JBoss
#	- a log4j.properties to override the logfile location
#
# Examples:
#
#	queryJBoss.pl jboss.jca
#
#	returns:
#		{#JBOSSJCA_JNDI}
#		{#JBOSSJCA_SERVICE}
#		{#JBOSSJCA_NAME}
#
#	queryJBoss.pl jboss.messaging.destination QUEUE
#
#	returns:
#		{#QUEUE_JNDI}
#		{#QUEUE_SERVICE}
#		{#QUEUE_NAME}
#
################################################################################
use strict;
use warnings;

# Options
my $_twiddle		= "/opt/jbossas/jboss-as/bin/twiddle.sh";
my $_twiddle_properties	= "/opt/zabbix/twiddle/twiddle.properties";
my $_twiddle_log4j	= "/opt/zabbix/twiddle/log4j.properties";

# Script arguments (no validating, needs improvements)
if (! defined $ARGV[0])
{
	die "No arguments given, need at least an Object Name Filter (i.e. jboss.jca)";
}
my $_objName = $ARGV[0];
my $_id = uc $_objName;
$_id =~ s/\.//g;

if (defined $ARGV[1])
{
	$_id = $ARGV[1];
}

# Keep count
my $_first = 1;

# Present the data in JSON format to the zabbix_agent
print "{\n";
print "\t\"data\":[\n\n";

# Fetch the data and put it in an array
my $_exec = "$_twiddle -P $_twiddle_properties";
my @_data = `export JAVA_OPTS="-Dlog4j.configuration=file:$_twiddle_log4j";$_exec query $_objName:*`;
chomp @_data;

foreach my $_jndi (@_data)
{
	# Print the data in JSON	
	print "\t,\n" if not $_first;
	$_first = 0;

	print "\t{\n";
	print "\t\t\"{#${_id}_JNDI}\":\"$_jndi\",\n";

	# Remove the object identifier information from the 
	# jndi string as we don't need in anymore.
	$_jndi =~ s/^.*?://;
	
	# Get the key/value pairs from the JBoss output
	my @_keyvalues = split(/,/, $_jndi);

	my $_f = 1;
	foreach my $_s (@_keyvalues)
	{	
		print ",\n" if not $_f;
		$_f = 0;
		my @_kv = split(/=/, $_s);
		my $_key = $_kv[0];
		$_key = uc $_key;
		my $_value = $_kv[1];
		print "\t\t\"{#${_id}_${_key}}\":\"$_value\"";
	}
	
	print "\n\t}\n";
}

print "\n\t]\n";
print "}\n";
