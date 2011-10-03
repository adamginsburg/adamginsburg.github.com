#! /usr/bin/perl -Tw

use strict;
use CGI;

my $cgiForm  = new CGI;

my $sendmail = "/usr/sbin/sendmail -t";
my $notify   = "y";

my $database = "signup.dat";
my $prevpage = "../observing.html";


#Get and untaint the data
my $group = &untaint($cgiForm->param('name'));
my $month = &untaint($cgiForm->param('month'));
my $day   = &untaint($cgiForm->param('day'));
my $time  = &untaint($cgiForm->param('time'));
my $class = &untaint($cgiForm->param('function'));
my $other = &untaint($cgiForm->param('other'));


#Create a webpage to display the results of their attempt
print "Content-type: text/html\n\n";
print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n";
print "    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "\n";
print "<html>\n";
print "\n";
print "<head>\n";
print "  <meta http-equiv=\"content-type\" content=\"text/html;";
print " charset=utf-8\"/>\n";
print "  <title>ASTR 3520: Sign-Up Submission</title>\n";
print "\n";
print "  <style type=\"text/css\">\n";
print "    h1 {text-align:center; font-weight:bold; color:#ff0000;}\n";
print "    td {border:1px solid #ffffff; text-align:center}\n";
print "    tr {border:1px solid #ffffff; text-align:center}\n";
print "  </style>\n";
print "</head>\n";
print "\n";
print "\n";
print "<body>\n";
print "\n";
print "  <p>&nbsp\;</p>\n";

# Check to ensure that the date submitted is valid
if ((($day eq "31") && (($month eq "September") || ($month eq "November")))) {

  print "  <h1> Invalid Date </h1>\n";
  print "\n";
  print "  <p>&nbsp\;</p>\n";
  print "  <p> \"$month $day\" is not a valid date. </p>\n";
  print "  <p> Please go back to the <a href=\"$prevpage\">\n";
  print "      previous page</a> and select another date. </p>\n";

} else {

  my @months;
  my @days;
  my @times;
  my @funcns;
  my @groups;
  my @others;

  # Read in the current data file
  open(INFILE, "< $database") or die "Cannot open database: $!";
  for(my $i=0; my $line = <INFILE>; $i++) {
    chomp($line);
    my @data  = split("\t", $line);
    my @dates = split(" ",  $data[0]);

    $times[$i]  = $data[1];
    $funcns[$i] = $data[2];
    $groups[$i] = $data[3];
	$others[$i] = $data[4];
    $months[$i] = $dates[0];
    $days[$i]   = $dates[1];
  }
  close(INFILE);


  # Check to see if the date requested has already been reserved
  my $reserved = "";

  for(my $i=0; $i<=$#groups; $i++) {
    if (($month eq $months[$i]) && ($day eq $days[$i]) && 
        ($time eq $times[$i])) { 
      $reserved = "yes"; 
    }
  }

  if($reserved) {

    print "  <h1> Failed Submission </h1>\n";
    print "\n";
    print "  <p>&nbsp\;</p>\n";
    print "  <p> The $time time slot on the night of $month $day has 
                 already been reserved. </p>\n";
    print "  <p> Please go back to the <a href=\"$prevpage\">\n";
    print "      previous page</a> and select another date. </p>\n";

  } elsif(($group eq "Enter a comma separated list of group members ") ||
          ($group eq "")) {

    print "  <h1> Failed Submission </h1>\n";
    print "\n";
    print "  <p>&nbsp\;</p>\n";
    print "  <p> No names were supplied. </p>\n";
    print "  <p> Please go back to the <a href=\"$prevpage\">\n";
    print "      previous page</a> and enter the names of your group\n";
    print "      members. </p>\n";

  } else {

    my $itime    = ($time eq "Early")  ? 0:
                   ($time eq "Middle") ? 1:
		                         2;
    my @itimes;
    for (my $i=0;$i<=$#times;$i++) {
      $itimes[$i] = ($times[$i] eq "Early")  ? 0:
                    ($times[$i] eq "Middle") ? 1:
		                               2;
    }

    my $funcn    = ($class eq "ASTR 3520") ? "3520" :
                                             "Other";
    if ($funcn eq "Other") {
      $class = &untaint($cgiForm->param('function'));
	  if ($class eq "Other") {
			  $other = &untaint($cgiForm->param('other'));
	  }
    } elsif ($funcn eq "3520") {
      $class = &untaint($cgiForm->param('function'));
	  $other = "";
	}

    # Inform the user that they have successfully been added.
    print "  <h1> Successful Submission </h1>\n";
	print " <link rel=\"stylesheet\" type=\"text/css\" href=\"../style.css\"> \n";
    print "\n";
    print "  <p>&nbsp\;</p>\n";
    print "  <p> The following information has been added to the observing\n";
    print "      schedule. Please check it for any errors. </p>\n";
    print "\n";
    print "  <table>\n";
    print "    <tr>\n";
    print "      <td style=\"width:20%\;\">Date:</td>\n";
    print "      <td style=\"width:80%\;\">$month $day</td>\n";
    print "    </tr>\n";
    print "    <tr>\n";
    print "      <td>Observers:</td>\n";
    print "      <td>$group</td>\n";
    print "    </tr>\n";
    print "    <tr>\n";
    print "      <td>Time Slot:</td>\n";
    print "      <td>$time</td>\n";
    print "    </tr>\n";
    print "    <tr>\n";
    print "      <td>Class:</td>\n";
    print "      <td>$class</td>\n";
    print "    </tr>\n";
	if ($other != "null") {
			print "    <tr>\n";
			print "      <td>Other:</td>\n";
			print "      <td>$other</td>\n";
			print "    </tr>\n";
	}
    print "  </table>\n";
    print "\n";
    print "  <p> If this information is incorrect, send \n";
    print "      <a href=\"mailto:adam.ginsburg\@colorado.edu?subject=Observing ";
    print                           "Sign-Up Problem/Change\">Adam</a>\n";
    print "      an email describing your problem. </p>\n";
    print "  <p> Please reload the <a href=\"$prevpage\">previous page</a>\n";
    print "      and check to make sure that your group appears on the\n";
    print "      calendar. </p>\n";
#	print "<br> 1. Was there some problem? $#groups";


    # Insert the observers' information into the database...
    open(OUTFILE, ">$database") or die "Cannot open database: $!";
#	print OUTFILE "Output worked, time to crash.";
#	print "<br> Was there some problem? $#groups";

    if ($#groups == -1) {

      print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";

    } else {

      my $inserted = 0;

      for (my $i=0; $i<=$#groups; $i++) {
        if ((!$inserted) && ($month eq $months[$i])) {
	  if ($day < $days[$i]) {
            print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
            print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
            $inserted = 1;
 	  } elsif ($day == $days[$i]) {
	    if ($itime < $itimes[$i]) {
              print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
              print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";              
              $inserted = 1;
            } elsif (($i != $#groups) && ($day == $days[$i+1])) {
              print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";              
  	    } else {
              print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";              
              print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
              $inserted = 1;
            }
          } elsif ($i == $#groups) {
            print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
            print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
            $inserted = 1;
          } else {
            print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
          }
        } elsif ((!$inserted) && ($i == $#groups)) {
          print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
          print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
          $inserted = 1;
        } elsif ((!$inserted) && ($month eq $months[$i-1])
                              && ($month ne $months[-1])) {
          print OUTFILE "$month $day\t$time\t$funcn\t$group\t$other\n";
          print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
          $inserted = 1;
        } else {
          print OUTFILE "$months[$i] $days[$i]\t$times[$i]\t$funcns[$i]\t$groups[$i]\t$others[$i]\n";
        }
      }
    }

    close(OUTFILE);


    # Now send me an email so that I know someone has been added...
    if ($notify) {
      $ENV{"PATH"} = "";
      open(SENDMAIL, "|$sendmail") or 
            die "Cannot open sendmail: $!";
      print SENDMAIL "From: 24-inch Scheduler ";
      print SENDMAIL "<ginsbura\@origins.colorado.edu>\n";
      print SENDMAIL "To: ginsbura\@colorado.edu\n";
      print SENDMAIL "Subject: New Group Added: $month $day\n";
      print SENDMAIL "Content-type: text/plain\n\n";
      print SENDMAIL "A new group has signed up to use the 24-inch.\n\n";
      print SENDMAIL "Date:  $month $day\n";
      print SENDMAIL "Time:  $time\n";
      print SENDMAIL "Group: $group\n";
      print SENDMAIL "Class: $class\n";
      print SENDMAIL "Other: $other\n";
      close(SENDMAIL);
    }
  }
}


# More html...
print "\n";
print "</body>\n";
print "</html>\n";



sub untaint {
  my $word = $_[0];
  if($word =~ m/([\w \-\&,.]+)/) {
    return $1;
  } else {
    return "";
  }
}
