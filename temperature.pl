#!/usr/bin/perl -w

use strict;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

my %config = do 'config.pl';

my $input;
my @values;
my $timestamp = 0;
my $output;

my $req = HTTP::Request->new( 'PUT', $config{pachube_feed_uri} );
$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $config{pachube_api_key} );
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
