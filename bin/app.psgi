#!/usr/bin/env perl

use strictures;

use FindBin;
use lib "$FindBin::Bin/../lib";

use kraftiworks;
use kraftiworks_admin;

use Plack::Builder;

builder {
    mount '/'      => kraftiworks->to_app;
#    mount '/admin'      => kraftiworks_admin->to_app;
}
