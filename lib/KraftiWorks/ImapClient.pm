#!/usr/bin/env perl

# KraftiWorks::ImapClient - A simple IMAP client for Perl
#
# Author: Gary L. Greene, Jr. <greeneg@yggdrasilsoft.com>
# Copyright: 2023 YggdrasilSoft, LLC.
# License: Apache License, Version 2.0
#
# This module provides a simple IMAP client for Perl. It uses the Net::IMAP::Simple
# module to connect to an IMAP server and perform basic operations such as
# listing mailboxes, selecting a mailbox, and fetching messages. It is designed
# to be easy to use and understand, while still providing the necessary functionality
# for most common use cases.
#
# This module is part of the KraftiWorks project, which aims to provide a web-based
# PIM client for managing email. The project is still in its early stages, and
# contributions are welcome. Please see the project's GitHub repository for more
# information.

package KraftiWorks::ImapClient {
    use strictures;
    use English;
    use utf8;

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use feature ":5.36";
    use feature qw(signatures);
    no warnings qw(experimental::signatures);

    use boolean qw(:all);
    use Data::Dumper;
    use Getopt::Long qw(:config gnu_compat);
    use MIME::Base64 qw( decode_base64 );
    use Return::Type;
    use Types::TypeTiny qw( BoolLike );
    use Types::Standard -all;

    use Dancer2;

    use KraftiWorks::AccountMapper;
    use KraftiWorks::MIME::Utils qw( rfc2047_decode );

    our $VERSION = '0.1';

    # Import the Net::IMAP::Simple module
    use Net::IMAP::SimpleX;

    sub new {
        my ($class, %args) = @_;
        my $self = bless {}, $class;

        # call account mapper to determine if we need an application password to login
        # to the remote IMAP server
        my $account_mapper = KraftiWorks::AccountMapper->new(
            username => $args{username},
        );
        my $imap_account = $account_mapper->get_account($args{username});
        if ($imap_account->{provider} eq 'gmail') {
            # check if we need an application password
            if ($imap_account->{application_password}) {
                $args{password} = decode_base64($imap_account->{application_password});
            }
        }

        # Set default values for the IMAP client
        $self->{server}   = $args{server}   // 'localhost';
        $self->{username} = $args{username} // '';
        $self->{password} = $args{password} // '';
        $self->{port}     = $args{port}     // 143;

        return $self;
    }

    our sub connect :ReturnType(BoolLike) ($self) {
        # Create a new IMAP client
        say STDERR "Connecting to IMAP server";
        say STDERR "Server: $self->{server}";
        say STDERR "Port: $self->{port}";
        $self->{imap} = Net::IMAP::SimpleX->new($self->{server}, port => $self->{port}, use_ssl => 1);

        # dump our returned object
        say STDERR "IMAP object: ", Dumper($self->{imap});

        # Check if the connection was successful
        if (!$self->{imap}) {
            say STDERR "Failed to connect to IMAP server:" . $Net::IMAP::Simple::errstr;
            return false;
        } else {
            say STDERR "Connected to IMAP server successfully";
        }

        # Authenticate with the server
        if (!$self->{imap}->login($self->{username}, $self->{password})) {
            say STDERR "Failed to login to IMAP server:" . $self->{imap}->errstr;
            return false;
        } else {
            say STDERR "Logged in to IMAP server successfully";
        }

        return true;
    }

    our sub list_folders :ReturnType(ArrayRef) ($self) {
        # List the folders on the IMAP server
        my @folders = $self->{imap}->mailboxes();
        if (!@folders) {
            say STDERR "Failed to list folders:" . $self->{imap}->errstr;
            return [];
        } else {
            say STDERR "Folders listed successfully";
        }

        return \@folders;
    }

    our sub list_subscribed_folders :ReturnType(ArrayRef) ($self) {
        # List the subscribed folders on the IMAP server
        my @folders = $self->{imap}->mailboxes_subscribed();
        if (!@folders) {
            say STDERR "Failed to list subscribed folders:" . $self->{imap}->errstr;
            return [];
        } else {
            say STDERR "Subscribed folders listed successfully";
        }

        return \@folders;
    }

    our sub select_folder :ReturnType(Str) ($self, $folder) {
        # Select a folder on the IMAP server
        my $selected = $self->{imap}->select($folder);
        if (!$selected) {
            say STDERR "Failed to select folder:" . $self->{imap}->errstr;
            return '';
        } else {
            say STDERR "Folder '$folder' selected successfully";
        }

        return $selected;
    }

    our sub msg_attribute :ReturnType(BoolLike) ($self, $msg_id, $attribute) {
        # get the attributes of a message
        if (defined(my @attributes = $self->{imap}->msg_flags($msg_id))) {
            if ($attribute eq 'read') {
                # check if the message is marked as read
                if (grep { $_ eq '\\Seen' } @attributes) {
                    return true;
                } else {
                    return false;
                }
            } else {
                say STDERR "Unknown attribute: $attribute";
                return false;
            }
        } else {
            say STDERR "Failed to get message attributes:" . $self->{imap}->errstr;
            return false;
        }

        return true;
    }

    our sub get_msg :ReturnType(ArrayRef) ($self, $msg_id) {
        # Get a message from the IMAP server
        my $msg = $self->{imap}->top($msg_id);
        if (!$msg) {
            say STDERR "Failed to get message:" . $self->{imap}->errstr;
            return [];
        }

        return $msg;
    }

    our sub get_msg_range :ReturnType(HashRef) ($self, $start, $end) {
        # Get a range of messages from the IMAP server
        say "Getting messages from $start to $end";
        my $header_list = "UID";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (SUBJECT)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (FROM)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (TO)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (CC)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (BCC)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (DATE)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (MESSAGE-ID)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (IN-REPLY-TO)]";
        $header_list .= " BODY.PEEK[HEADER.FIELDS (REFERENCES)]";
        $header_list .= " FLAGS";
        my $msg_headers = $self->{imap}->fetch("${start}:${end}" => $header_list);
        foreach my $msg_id (keys %{$msg_headers}) {
            chomp (my $msg_from = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (FROM)]'});
            chomp (my $msg_to = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (TO)]'});
            chomp (my $msg_cc = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (CC)]'});
            chomp (my $msg_bcc = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (BCC)]'});
            chomp (my $msg_date = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (DATE)]'});
            chomp (my $msg_message_id = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (MESSAGE-ID)]'});
            chomp (my $msg_in_reply_to = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (IN-REPLY-TO)]'});
            chomp (my $msg_references = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (REFERENCES)]'});
            chomp (my $msg_subject = $msg_headers->{$msg_id}->{'BODY[HEADER.FIELDS (SUBJECT)]'});
            chomp (my $msg_uid = $msg_headers->{$msg_id}->{'UID'});
            say "----------------------------------------";
            say "Message ID: $msg_id";
            say"FLAGS: ", join(", ", @{$msg_headers->{$msg_id}->{FLAGS}});
            print $msg_from;;
            print $msg_to;
            print $msg_cc if $msg_cc ne "";
            print $msg_bcc if $msg_bcc ne "";
            print $msg_date;
            print $msg_message_id;
            print $msg_in_reply_to;
            print $msg_references;
            say "UID: ", $msg_uid;
            my $subject = $msg_subject;
            $subject =~ s/\n//g;
            $subject =~ s/\r//g;
            $subject = rfc2047_decode($subject);
            say $subject;
            say "----------------------------------------";
        }
        exit 0;

        return $msg_headers;
    }

    our sub get_folder_separator :ReturnType(Str) ($self) {
        # Get the folder separator for the IMAP server
        my $folder_separator = $self->{imap}->separator();
        if (!$folder_separator) {
            say STDERR "Failed to get folder separator:" . $self->{imap}->errstr;
            return '';
        } else {
            say STDERR "Folder separator: $folder_separator";
        }
        return $folder_separator;
    }

    our sub disconnect :ReturnType(Void) ($self) {
        # Disconnect from the IMAP server
        say STDERR "Disconnecting from IMAP server";
        if ($self->{imap}) {
            $self->{imap}->logout();
            say STDERR "Disconnected from IMAP server";
        } else {
            say STDERR "No IMAP connection to disconnect from";
        }
    }

    true;
}