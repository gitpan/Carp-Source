use inc::Module::Install;
name 'Carp-Source';
all_from 'lib/Carp/Source.pm';
perl_version '5.006';

requires 'Term::ANSIColor';

build_requires 'Test::Differences';
build_requires 'Test::More' => '0.70';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
