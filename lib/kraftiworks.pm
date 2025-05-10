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

    our sub main :ReturnType(Void) (@args) {
        my $sub = (caller(0))[3];

        set traces => 1;

        get '/' => sub {
            template 'index' => { 'title' => 'kraftiworks' };
        };
    }
    main(@ARGV);

    true;
}
