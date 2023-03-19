#!/usr/bin/env perl
#
# Author: Gary Greene <greeneg@tolharadys.net>
# Copyright: 2023 YggdrasilSoft, LLC.
#
##########################################################################
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package main {
    use strictures;
    use English;
    use utf8;

    use FindBin;
    use lib "$FindBin::Bin/../lib";

    use feature ":5.36";

    use boolean qw(:all);
    use Return::Type;
    use Types::Standard -all;

    use kraftiworks;

    use Plack::Builder;

    my sub main :ReturnType(Void) (@args) {
        return builder {
            mount '/'      => kraftiworks->to_app;
        }
    }

    main(@ARGV);
}
