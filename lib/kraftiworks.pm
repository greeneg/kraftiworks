package kraftiworks {
    use strictures;
    use English;
    use utf8;

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use feature ":5.36";

    use boolean qw(:all);
    use Return::Type;
    use Types::Standard -all;

    use Dancer2;

    our $VERSION = '0.1';

    get '/' => sub {
        template 'index' => { 'title' => 'kraftiworks' };
    };

    true;
}
