#!/usr/bin/env perl

package main {
    use strict;
    use warnings;
    use utf8;
    use English;

    use boolean qw(:all);
    use Getopt::Long qw(:config gnu_compat);

    use feature ':5.36';
    use feature 'signatures';
    no warnings 'experimental::signatures';

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use KraftiWorks::ImapClient;

    my $imap_client = KraftiWorks::ImapClient->new(
        server   => $ENV{KRAFTIWORKS_IMAP_SERVER},
        port     => 993,
        username => $ENV{KRAFTIWORKS_USERNAME},
        password => '',
    );
    my $connected = $imap_client->connect();
    $imap_client->disconnect();
    exit 0;
}
