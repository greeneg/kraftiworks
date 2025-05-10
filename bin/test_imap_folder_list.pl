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
        server   => 'imap.gmail.com',
        port     => 993,
        username => 'greeneg@tolharadys.net',
        password => '',
    );
    my $connected = $imap_client->connect();
    my $folder_separator = $imap_client->get_folder_separator();
    my $folders = $imap_client->list_folders();
    if ($folders) {
        say "Folders:";
        foreach my $folder (sort @$folders) {
            say "  $folder";
        }
    } else {
        say "No folders found";
    }
    my $subbed_folders = $imap_client->list_subscribed_folders();
    if ($subbed_folders) {
        say "Subscribed Folders:";
        foreach my $folder (sort @$subbed_folders) {
            say "  $folder";
        }
    } else {
        say "No subscribed folders found";
    }
    $imap_client->disconnect();
    exit 0;
}
