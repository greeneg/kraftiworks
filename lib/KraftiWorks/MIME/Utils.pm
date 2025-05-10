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
    use Return::Type;
    use Types::TypeTiny qw( BoolLike );
    use Types::Standard -all;

    our $VERSION = '0.1';

    our sub rfc2047_decode :ReturnType(BoolLike) ($string) {
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
            }
        }

        my $updated_string = $header . ": " . $decoded_string;

        # Return the decoded string
        return $updated_string;
    }

    true;
}