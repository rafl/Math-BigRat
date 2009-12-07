use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Math-BigRat',
    'VERSION_FROM'	=> 'lib/Math/BigRat.pm', # finds $VERSION
    'PREREQ_PM'		=> {
			   Math::BigInt => 1.61,
			   Math::BigFloat => 1.36,
			   }, # e.g., Module::Name => 1.1
    'INSTALLDIRS'	=> 'perl',
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '', # e.g., '-I/usr/include/other'
);