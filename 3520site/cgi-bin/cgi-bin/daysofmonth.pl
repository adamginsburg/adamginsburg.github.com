#! /usr/bin/perl -w

use strict;

print "Content-type: text/html\n\n";

for(my $i=1;$i<=31;$i++) {
    print "                              <option>$i</option>\n";
}
