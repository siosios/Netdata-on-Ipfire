#!/usr/bin/perl
# Menüerweiterung für Ipfire
 
use strict;
use Switch;
 
switch ($ENV{'QUERY_STRING'}) {
 
    case "netdata" {
 
	print "Content-type: text/html\n\n";
 
	print <<EOF
	<head>
	<script type="text/javascript">window.open('https://$ENV{'SERVER_ADDR'}:19999');</script>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta http-equiv="refresh" content="0;https://$ENV{'SERVER_ADDR'}:444">
	</head>
EOF
	;
    }
 
   
 
}
