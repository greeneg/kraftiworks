package KraftiWorks::MIME::Utils {
    use strictures;
    use English;
    use utf8;

    use parent 'Exporter';
    our @EXPORT_OK = qw( rfc2047_decode );
    our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );
    our @EXPORT = qw( rfc2047_decode );

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use feature ":5.36";
    use feature qw(signatures);
    no warnings qw(experimental::signatures);

    use boolean qw(:all);
    use Data::Dumper;
    use MIME::Base64 qw( decode_base64 );
    use MIME::QuotedPrint qw( decode_qp );
    use Return::Type;
    use Types::TypeTiny qw( BoolLike );
    use Types::Standard -all;

    our $VERSION = '0.1';

    our sub rfc2047_decode :ReturnType(BoolLike) ($string) {
        # remove any carriage returns and line feeds
        $string =~ s/\n//g;
        $string =~ s/\r//g;

        # Decode a string encoded in RFC 2047 format
        if ($string !~ m/\=\?.*\?\=/g) {
            # string is not encoded
            return $string;
        }

        # split string into parts
        my ($header, $encoded_string) = split(': ', $string);

        # now split the encoded string into encoded word parts
        my @encoded_words = split(/\s+/, $encoded_string);

        my $decoded_string = '';
        # now process each encoded word
        foreach my $encoded_word (@encoded_words) {
            # check if the encoded word is in the format =?UTF-8?B?
            if ($encoded_word =~ m/\=\?UTF-8\?B\?(.*)\?\=/i) {
                # decode the base64 string
                my $word = $1;
                $decoded_string .= decode_base64($1);
                $decoded_string .= " ";
            } elsif ($encoded_word =~ m/\=\?UTF-8\?Q\?(.*)\?\=/i) {
                # decode the quoted-printable string
                my $word = $1;
                # quoted-printable strings are encoded with = and _ characters
                # so we need to replace them with the correct characters
                $decoded_string .= decode_qp($1);
                # replace any underscores with spaces
                $decoded_string =~ s/_/ /g;
            } else {
                # not an encoded word, just add it to the decoded string
                $decoded_string .= $encoded_word . " ";
            }
        }

        # Remove any trailing whitespace and newlines
        $decoded_string =~ s/\s+$//;
        # Remove any leading whitespace
        $decoded_string =~ s/^\s+//;

        my $updated_string = $header . ": " . $decoded_string;

        # Return the decoded string
        return $updated_string;
    }

    true;
}