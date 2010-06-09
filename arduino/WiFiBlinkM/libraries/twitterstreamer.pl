#!/usr/bin/env perl 

#
# twitterstreamer.pl -- 
#
#
#
#

use strict;
use warnings;

use IO::Socket;
use IO::Select;
use MIME::Base64;
#use Time::Hires qw(time);

my $debug = 0;

# change this to be your own Twitter login
my $twuser = "blinkmlive";
my $twpass = "redgrenblue";

# only three are allowed
my @keywords = 
    (
     "colbert,colbertreport,dailyshow,stephenathome", 
     "grizzlies,grizzly,america",
     "freedom,usa"
    );

# the file to write to
#my $countsfile = "/home/83337/users/.home/todbot.com/colberttweets/index.php";
my $countsfile = "index.php";

my $keywords_counts = {};

# how 
my $duration = 5 * 59;  # 5 minutes, minus a little
my $perduration = 10;
my $selsecs = 1;



my $twBaseUrl = "http://stream.twitter.com/1/statuses/filter.json";

my $keywordstr = join( ',', grep { !"" } @keywords);
$keywordstr =~ s/^,//; # sigh, remove leading comma, if any

my $host = "stream.twitter.com";
my $uri =  "/1/statuses/filter.json?track=$keywordstr";
my $auth = encode_base64("$twuser:$twpass","");

#
sub debug($;$) {
    my ($str,$lvl) = @_;
    $lvl ||= 1;
    print $str if($debug>=$lvl);
}

debug("uri:$uri\n");
debug("auth: $auth\n");

#
sub updateFile() {

    my $cstr = 
	"<?php header('Content-type: text/plain'); ?>\n".
        "// ".localtime(). "\n".
        "// list of three different keywordsets tweet count\n".
        "// each color count causes that many flashes.\n".
        "// keywords: ";
    foreach my $k (@keywords) {
        $cstr .= $k .";  ";
    }
    $cstr .="\n";
    $cstr .= "#";

    # get counts
    foreach my $k (@keywords) { 
        my $v = $keywords_counts->{$k};
        $cstr .= sprintf( "%02x", $v);
        debug("$k : $v\n");
    }

    open( my $fh, '>', $countsfile) or die $!;  # FIXME
    print $fh "$cstr\n";
    close( $fh );
}

#
sub getTweets() {
    my $sock = IO::Socket::INET->new( Proto => 'tcp',
                                      PeerAddr => $host,
                                      PeerPort => 'http(80)',
                                      timeout  => $perduration,
        );
    if( !$sock ) {
        debug("couldn't connect");
        return 0;
    }
    
    print $sock "GET $uri HTTP/1.1\n";
    print $sock "Host: $host\n";
    print $sock "Authorization: Basic $auth\n";
    print $sock "User-Agent: todbot.com twitterstreamer 0.5\n";
    print $sock "Accept: */*\n";
    print $sock "\n";
    
    my $starttime = time();
    debug("getTweets: $starttime (". localtime() .")\n");
    
    my $sel = new IO::Select( $sock );
    
    my $maxt = $starttime + $perduration;
    while( time() < $maxt ) {
        if( $sel->can_read( $selsecs ) ) {
            my $line = <$sock>;
            debug("line: $line",2);
            foreach my $k (@keywords) { 
                foreach my $kk (split ',', $k) {  # in case of multi-word 
                    $keywords_counts->{$k}++ if( $line =~ /$kk/i );
                }
            }
        }
    }
    close($sock);
    return 1;
}

my $startt = time();
my $endt = $startt + $duration;
while( time() < $endt ) {
    foreach my $k (@keywords)  { 
        $keywords_counts->{$k} = 0;  # reset
    }
    if( getTweets() ) {  # each of these takes $perduration seconds
        updateFile();
    }
}



#------------------------------------------------------------

#while( my $line = <$sock> ) { 
#    printf "len: %x\n", length($line);
#    print $line;
#    my $t = time();
#    print "time: $t\n";
#}



#sub encode_base64 { 
#    use integer;
#    my $res = ""; 
#    pos( $_[0] )= 0; 
#    while ( $_[0] =~ /(.{1,45})/gs ) {
#        $res .= substr( pack('u', $1 ), 1 );
#        chop($res);
#    } 
#    $res =~ tr |' -_|AA-Za-z0-9+/|; 
#    my $padding = ( 3 - length( $_[0] )% 3 )% 3; 
#    $res =~ s/.{$padding}$/'=' x $padding/e if $padding; 
#    return $res;
#}



    

