#!/usr/bin/perl -w

use strict;

BEGIN {
 # Fork.
 my $pidFile = '/var/run/rzl-temperature-mon.pid';
 my $pid = fork;
 if ($pid) # parent: save PID
 {
  open PIDFILE, ">$pidFile" or die "can't open $pidFile: $!\n";
  print PIDFILE $pid;
  close PIDFILE;
  exit 0;
 }
}

use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

# Configuration
my $pachube_feed_uri = 'http://api.pachube.com/v2/feeds/42055';
my $pachube_api_key = 'INSERT_PACHUBE_API_KEY';

my $input;
my @values;
my $timestamp = 0;
my $output;

my $req = HTTP::Request->new( 'PUT', $pachube_feed_uri );
$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $pachube_api_key );
my $lwp = LWP::UserAgent->new;
my $response;

while (1) {
	# Get input from log file (the ugly way)
	$input = `curl -r -60 http://blackbox.raumzeitlabor.de/temperatur/log 2>/dev/null | tail -n 1`;
	
	# Input Sanity Check
	if ($input =~ m/^\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\r\n$/ ) {
		@values = split(/ /, $input);
		
		# Only update if new values found
		if ($timestamp != $values[0]) {
			$timestamp = $values[0];
			$output = "{
		  \"version\":\"1.0.0\",
		  \"datastreams\":[
			  {\"id\":\"Temperatur_Heizung_Vorlauf\", \"current_value\":\"" . $values[1]/100 . "\"},
			  {\"id\":\"Temperatur_Heizung_Ruecklauf\", \"current_value\":\"" . $values[2]/100 . "\"},
			  {\"id\":\"Temperatur_Raum_Tafel\", \"current_value\":\"" . $values[3]/100 . "\"},
			  {\"id\":\"Temperatur_Raum_Beamerplattform\", \"current_value\":\"" . $values[4]/100 . "\"}
		  ]
		}\n";
		
			# Send request to Pachube
			$req->content( $output );
			$response = $lwp->request( $req );
		}
	}
	sleep(60);
}
