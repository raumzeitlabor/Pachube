#!/usr/bin/perl -w

use strict;

BEGIN {
 # Fork.
 my $pidFile = '/var/run/rzl-electricity-mon.pid';
 my $pid = fork;
 if ($pid) # parent: save PID
 {
  open PIDFILE, ">$pidFile" or die "can't open $pidFile: $!\n";
  print PIDFILE $pid;
  close PIDFILE;
  exit 0;
 }
}

use File::Basename;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

my %config = do dirname(__FILE__) . '/config.pl';

my $input;
my @values;
my $timestamp = 0;
my $output;
my $power;

my $req = HTTP::Request->new( 'PUT', $config{pachube_feed_uri} );
$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $config{pachube_api_key} );
my $lwp = LWP::UserAgent->new;
my $response;

while (1) {
	# Get input from log file (the ugly way)
	$input = `curl -r -60 http://blackbox.raumzeitlabor.de/strom/data/log 2>/dev/null| tail -n 2`;
	
	# Input Sanity Check
	if ($input =~ m/^\d+\s\d+\s\r\n\d+\s\d+\s\r\n$/ ) {
		@values = split(/[ \n\r]+/, $input);
		
		# Only update if new values found
		if ($timestamp != $values[2]) {
			$power = ($values[3] - $values[1]) * 3600/($values[2] - $values[0]);
			$timestamp = $values[0];
			$output = "{
		  \"version\":\"1.0.0\",
		  \"datastreams\":[
			  {\"id\":\"Strom_Leistung\", \"current_value\":\"" . $power . "\"},
			  {\"id\":\"Strom_Gesamtverbrauch\", \"current_value\":\"" . $values[3]/1000 . "\"}
		  ]
		}\n";
			
			# Send request to Pachube
			$req->content( $output );
			$response = $lwp->request( $req );
		}
	}
	sleep(60);
}
