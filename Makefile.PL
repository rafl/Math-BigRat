
use strict;

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# The name of your distribution
name		'Math-BigRat';

# Get most of the details from the primary module
all_from	'lib/Math/BigRat.pm';

requires	'perl'		=> "5.006002";
requires	'Math::BigInt'	=> 1.79;

build_requires	'Test::More'	=> 0.47;

license		'gpl';

author		'Tels <nospam-abuse@bloodgate.com>';

# install this over the version in the Perl core
makemaker_args INSTALLDIRS => 'perl';

# We cannot work without our prerequisites
makemaker_args PREREQ_FATAL => 1;

# Generate the Makefile
WriteAll;
