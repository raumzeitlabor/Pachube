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

my $uri = 'http://api.pachube.com/v2/feeds/42055';
my $req = HTTP::Request->new( 'PUT', $uri );
$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $api_key );
my $lwp = LWP::UserAgent->new;
my $response;

while (1) {
	$input = `curl -r -60 http://blackbox.raumzeitlabor.de/temperatur/log 2>/dev/null | tail -n 1`;
	@values = split(/ /, $input);
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
		$req->content( $output );
		# print Dumper $req;
		$response = $lwp->request( $req );
		# print $response->status_line . "\n";
	}
	sleep(60);
}
