use strictures;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'kraftiworks',
    AUTHOR              => q{Gary Greene <greeneg@tolharadys.net>},
    VERSION_FROM        => 'lib/kraftiworks.pm lib/kraftiworks.pm',
    ABSTRACT            => 'Webmail, Calendar, and Addressbook front and back end',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'apachev2')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer2'     => 0.400001,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'kraftiworks-*' },
);
