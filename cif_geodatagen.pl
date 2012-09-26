#!/usr/bin/perl
use Geo::IP;
use warnings;
use strict;

my $gi = Geo::IP->open("/usr/local/share/GeoIP/GeoIPCity.dat", GEOIP_STANDARD);

##Grabs data from feeds
open HOURLY, "/home/cif/crontool_hourly.log" or die "issue opening $!\n" ;
open DAILY, "/home/cif/crontool_daily.log" or die " issue opening $!\n";


my $json;
my $convert_magnitude;
my $ip;
my $record;
my $lat;
my $lon;

#Generates first data series for the JSON (1 hour)
$json .= "[";
$convert_magnitude=.05;
while (my $hourly_line = <HOURLY>) {

  if ( $hourly_line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
	$ip = $1;
	$ip =~ s/\.0/\.1/g;
	my $record = $gi->record_by_name("$ip");
	
	#checks to see if it found the IP in the database
	if ( defined $record ) { 
		$lat = $record->latitude;
		$lon = $record->longitude;
			#LONGITUDE    LATITUDE     HEIGHT OF SPIKE IN GLOBE  COLOR CODE
		$json .= $lat . "," . $lon . "," . $convert_magnitude . "," . "7" . ",\n";
  	}
   }

}

$convert_magnitude=.02;
while (my $hourly_line = <DAILY>) {

  if ( $hourly_line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
        $ip = $1;
        $ip =~ s/\.0/\.1/g;
        my $record = $gi->record_by_name("$ip");
        
        #checks to see if it found the IP in the database
        if ( defined $record ) {
                $lat = $record->latitude;
                $lon = $record->longitude;
                $json .= $lat . "," . $lon . "," . $convert_magnitude . "," . "16" . ",\n";
        }
   }

}

#closing caret for the json
$json .= "]";
close HOURLY;
close DAILY;

#remove trailing ,
$json =~ s/,\n\]/]/; 
$json =~ s/,\]\]/]]/;
$json =~ s/,\]\]\]/]]]/;

open (FILE, '>/var/www/attack_data.json');
print FILE $json;
close (FILE);
