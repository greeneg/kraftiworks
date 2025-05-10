package KraftiWorks::AccountMapper {
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
    use JSON::XS qw( decode_json );
    use Return::Type;
    use Types::TypeTiny qw( BoolLike );
    use Types::Standard -all;
    use Syntax::Keyword::Try qw( try catch finally :experimental );

    our $VERSION = '0.1';

    sub new {
        my ($class, %args) = @_;
        my $self = bless {}, $class;

        # Set default values for the IMAP client
        $self->{username} = $args{username} // '';

        return $self;
    }

    our sub get_account :ReturnType(HashRef) ($self, $username) {
        say STDERR "Getting account for $username";
        my ($user, undef) = split("@", $username);
        my $fh = undef;
        try {
            # find and open json file that contains the account information
            my $file = "$FindBin::Bin/../config/databackend/json/${user}.json";
            open $fh, '<', $file or die "Could not open file '$file' $!";
        } catch ($e) {
            say STDERR "Error: $e";
            return {
                provider => 'unknown',
                application_password => '',
            };
        }

        # read the json file
        my $json = '';
        try {
            read $fh, $json, -s $fh;
        } catch ($e) {
            say STDERR "Error: $e";
            return {
                provider => 'unknown',
                application_password => '',
            };
        }

        # close the file handle
        try {
            close $fh;
        } catch ($e) {
            say STDERR "Error: $e";
            return {
                provider => 'unknown',
                application_password => '',
            };
        }

        # parse the json file
        my $account = {};
        try {
            $account = decode_json($json);
        } catch ($e) {
            say STDERR "Error: $e";
            return {
                provider => 'unknown',
                application_password => '',
            };
        }

        return $account;
    }

    true;
}