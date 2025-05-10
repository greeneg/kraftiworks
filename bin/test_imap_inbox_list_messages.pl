#!/usr/bin/env perl

package main {
    use strict;
    use warnings;
    use utf8;
    use English;

    use boolean qw(:all);
    use Email::Simple;
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
    my $folder_separator = $imap_client->get_folder_separator();
    my $subbed_folders = $imap_client->list_subscribed_folders();
    if ($subbed_folders) {
        say "Subscribed Folders:";
        foreach my $folder (sort @$subbed_folders) {
            say "  $folder";
        }
    } else {
        say "No subscribed folders found";
    }
    say "Selecting INBOX";
    my $selected = $imap_client->select_folder('INBOX');
    say "Getting the first 100 messages";
    my $messages = $imap_client->get_msg_range(($selected - 100), $selected);
#    for (my $i = $selected; $i > 0; $i--) {
#        if (! $imap_client->msg_attribute($i, 'read')) {
#            print "* ";
#        } else {
#            print "  ";
#        }
#
#        my $email = Email::Simple->new(join "", @{ $imap_client->get_msg($i) });
#        printf("[%03d] %s\n", $i, $email->header('Subject'));
#    }
    $imap_client->disconnect();
    exit 0;
}
