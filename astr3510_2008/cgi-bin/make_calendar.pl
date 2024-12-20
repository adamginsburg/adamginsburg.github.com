#!/usr/bin/perl -w

use strict;

my $database = "signup.dat";

#my @months = ("September","October","November","December");
my @months = ("January","February","March","April","May");
my @nwks   = (5,5,6,5,5);
my @ndays  = (31,29,31,30,31);
my @stday  = (2,5,6,2,4);
my $ctr    = 0;

my @mths;
my @days;
my @times;
my @funcns;
my @groups;
my @others;


# Determine today's date so that it can be highlighted in the calendar
my @junk = localtime(time);
my $today = $junk[3];
my $thismonth;

if ($junk[4] == 0) {
  $thismonth = "January";
} elsif ($junk[4] == 1) {
  $thismonth = "February";
} elsif ($junk[4] == 2) {
  $thismonth = "March";
} elsif ($junk[4] == 3) {
  $thismonth = "April";
} elsif ($junk[4] == 4) {
  $thismonth = "May";
} elsif ($junk[4] == 5) {
  $thismonth = "June";
} else {
  $thismonth = "January";
  $today     = 1;
}


# Read in the data file with signup information. This routine assumes that
# the data are sorted by date, so this has to be taken care of beforehand.
open(INFILE, "< $database") or die "Cannot open database: $!";
for(my $i=0; my $line = <INFILE>; $i++) {
  if ($line =~ /^#/) {
	$i--;
	next;
	}
  chomp($line);
  my @data  = split("\t", $line);
  my @dates = split(" ",  $data[0]);

  $times[$i]  = $data[1];
  $funcns[$i] = $data[2];
  $groups[$i] = $data[3];
  $others[$i] = $data[4];
  $mths[$i]   = $dates[0];
  $days[$i]   = $dates[1];
}
close(INFILE);


# Create the html to generate the calendar
print "Content-type: text/html\n\n";

for (my $mth=0; $mth <= $#months; $mth++) {
  print "  <p>&nbsp\;</p>\n";
  print "  <h2> $months[$mth] 2008 </h2>\n";
  print "\n";
  print "  <p>&nbsp;</p>\n";
  print "  <div style=\"text-align:center\;\">\n";
  print "    <table style=\"border: 2px solid #ffffff\; margin:auto\; ";
  print            "border-collapse:collapse\; text-align:left\;\">\n";
  print "      <tr>\n";
  print "        <th>Sunday</th>\n";
  print "        <th>Monday</th>\n";
  print "        <th>Tuesday</th>\n";
  print "        <th>Wednesday</th>\n";
  print "        <th>Thursday</th>\n";
  print "        <th>Friday</th>\n";
  print "        <th>Saturday</th>\n";
  print "      </tr>\n";

  my $day = 1;

  for (my $i=0; $i < $nwks[$mth]; $i++) {  
    print "      <tr class=\"top\">\n";

    for (my $j=0; $j < 7; $j++) {

      if ($i == 0) {

	if ($j < $stday[$mth]) {

          print "        <td class=\"cal\"></td>\n";

        } else {

	  my $emptydate = 1;

          while (($ctr <= $#groups) && ($mths[$ctr] eq $months[$mth]) &&
                 ($days[$ctr] == $day)) {

	    $emptydate = 0;
            my $class = ($funcns[$ctr] eq "3510")  ? "ugrad" :
                                                     "other" ;

            if (($days[$ctr] != $days[$ctr-1]) ){#|| 
#                ($mths[$ctr] == $mths[$ctr-1])) {
              if (($thismonth eq $months[$mth]) && ($today == $day)) {
                print "        <td class=\"cal\" style=\"background-color:#55AA55\;\"><h1>$day</h1><br/><br/>";
  	      } else {
                print "        <td class=\"cal\">$day<br/><br/>";
#                print " Days: $days[$ctr] mths: $mths[$ctr] \n";
    	      }
	    }

	    print "<em>$times[$ctr]:</em><br/>";
            print "<span class=\"$class\">$groups[$ctr]</span><br/><br/>\n";
			if (defined($others[$ctr]) && $others[$ctr] ne "null") {print "Task:  <span class=\"$class\">$others[$ctr]</span><br/><br/>\n";}
#            my @names = split(",", $groups[$ctr]);
#            for(my $k=0; $k <= $#names; $k++) {
#	      if ($#names == 0) {
#                print "<em>$times[$ctr]:</em><br/>\n";
#                print "<span class=\"$class\">$names[0]</span><br/>\n";
#              } elsif ($k == 0) {
#                print "<em>$times[$ctr]:</em><br/>\n";
#                print "<span class=\"$class\">$names[$k],<br/>";
#              } elsif ($k == $#names) {
#                print "$names[$k]</span><br/><br/>";
#              } else {
#                print "$names[$k],<br/>";
#              }
#	    }

            $ctr++;
	  }

          if ($emptydate) {
            if (($thismonth eq $months[$mth]) && ($today == $day)) {
              print "        <td class=\"cal\" style=\"background-color:#55AA55\;\"><h1>$day</h1>";
  	    } else {
              print "        <td class=\"cal\">$day";
    	    }
          }

          print "</td>\n";
          $day++;
	}

      } else {

	if ($day <= $ndays[$mth]) {

	  my $emptydate = 1;

#print "counter $ctr  groups $#groups  month: $mth day: $day<br>";
#print "$days[$ctr] == $day\t\t";
#print "$mths[$ctr] eq $months[$mth]<br>";
          while (($ctr <= $#groups) && ($mths[$ctr] eq $months[$mth]) &&
              ($days[$ctr] == $day)) {

	    $emptydate = 0;
            my $class = ($funcns[$ctr] eq "3510")  ? "ugrad" :
                                                     "other" ;

            if (($days[$ctr] != $days[$ctr-1])){# || 
#                ($mths[$ctr] == $mths[$ctr-1])) {
              if (($thismonth eq $months[$mth]) && ($today == $day)) {
                print "        <td class=\"cal\" style=\"background-color:#55AA55\;\"><h1>$day</h1><br/><br/>";
  	      } else {
                print "        <td class=\"cal\">$day<br/><br/>";
    	      }
	    }

	    print "<em>$times[$ctr]:</em><br/>";
            print "<span class=\"$class\">$groups[$ctr]</span><br/><br/>\n";
			if (defined($others[$ctr]) && $others[$ctr] ne "null") {print "Task: <span class=\"$class\">$others[$ctr]</span><br/><br/>\n";}
#            my @names = split(",", $groups[$ctr]);
#            for(my $k=0; $k <= $#names; $k++) {
#	      if ($#names == 0) {
#                print "<em>$times[$ctr]:</em><br/>\n";
#                print "<span class=\"$class\">$names[0]</span><br/>\n";
#	      } elsif ($k == 0) {
#                print "<em>$times[$ctr]:</em><br/>\n";
#	        print "<span class=\"$class\">$names[$k],<br/>";
#  	      } elsif ($k == $#names) {
#                print "$names[$k]</span><br/><br/>";
#	      } else {
#                print "$names[$k],<br/>";
#	      }
#	    }

            $ctr++;
          }

          if ($emptydate) {
            if (($thismonth eq $months[$mth]) && ($today == $day)) {
              print "        <td class=\"cal\" style=\"background-color:#55AA55\;\"><h1>$day</h1>";
  	    } else {
              print "        <td class=\"cal\">$day";
    	    }
          }

          print "</td>\n";
          $day++;

        } else {
          print "        <td class=\"cal\"></td>\n";
        }
      }
    }

    print "      </tr>\n";
  }

  print "    </table>\n";
  print "  </div>\n\n\n";
  if ($mth != $#months) {
    print "  <p>&nbsp\;</p>\n";
  }

}
