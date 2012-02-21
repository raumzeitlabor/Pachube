package RaumZeitLabor::ElectricityPachube;

use strict;
use YAML::Syck;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;

our $VERSION = '1.0';

my $input;
my @values;
my $timestamp = 0;
my $output;
my $power;

my $cfg;
if (-e 'electricity-pachube.yml') {
    $cfg = LoadFile('electricity-pachube.yml');
} elsif (-e '/etc/electricity-pachube.yml') {
    $cfg = LoadFile('/etc/electricity-pachube.yml');
} else {
    die "Could not load ./electricity-pachube.yml or /etc/electricity-pachube.yml";
}

sub run {
	my $req = HTTP::Request->new( 'PUT', $cfg->{pachube_feed_uri} );
	$req->header( 'Content-Type' => 'application/json', 'X-PachubeApiKey' => $cfg->{pachube_api_key} );
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
}

1

__END__


=head1 NAME

ElectricityPachube - pushes electricity values to pachube

=head1 DESCRIPTION

This module reads electricity usage from the blackbox and pushes them to
pachube.

=head1 VERSION

Version 1.0

=head1 AUTHOR

Severin Schols, C<< <severin at schols.de> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Severin Schols

This program is free software; you can redistribute it and/or modify it
under the terms of the BSD license.

=cut
