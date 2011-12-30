#!/usr/bin/perl -w

use strict;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

use Data::Dumper;

my $api_key = "INSERT_PACHUBE_API_KEY_HERE";

my $input;
my @values;
my $timestamp = 0;
my $output;
my $power;

my $uri = 'http://api.pachube.com/v2/feeds/42055';
my $req = HTTP::Request->new( 'PUT', $uri );
$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $api_key );
my $lwp = LWP::UserAgent->new;
my $response;

while (1) {
	$input = `curl -r -60 http://blackbox.raumzeitlabor.de/strom/data/log 2>/dev/null| tail -n 2`;
	@values = split(/[ \n\r]+/, $input);
	
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
		#print $output;
		$req->content( $output );
		# print Dumper $req;
		$response = $lwp->request( $req );
		# print $response->status_line . "\n";
	}
	sleep(60);
}
