use ExtUtils::MakeMaker;

sub MY::metafile {
  package MY;
  my $self = shift;
  if (!eval { require YAML; 1 })
  {
    warn ("YAML not installed, cannot override metafile"); return $self->SUPER::metafile_target(@_);
  };

  my $node = new YAML::Node {};

  $node->{name}                 = $self->{DISTNAME};
  $node->{version}              = $self->{VERSION};
  $node->{version_from}         = $self->{VERSION_FROM};
  $node->{license}              = 'perl';
  $node->{distribution_type}    = 'module';
  $node->{generated_by}         = "$self->{DISTNAME} version $self->{VERSION}";
  $node->{installdirs}          = 'perl';
  $node->{requires}             = $self->{PREREQ_PM};

  my $dump = YAML::Dump( $node );

  $dump =~ s/^(.*)$/\t\$(NOECHO) \$(ECHO) "$1" >>META.yml/gm;
  $dump =~ s/>>META\.yml/>META.yml/;

  return "metafile:\n$dump";
}


WriteMakefile(
    'NAME'		=> 'Math-BigRat',
    'VERSION_FROM'	=> 'lib/Math/BigRat.pm', # finds $VERSION
    'PREREQ_PM'		=> {
			   Math::BigInt => 1.75,
			   Math::BigFloat => 1.50,
			   Test::Simple => 0.47,
			   }, # e.g., Module::Name => 1.1
    'INSTALLDIRS'	=> 'perl',
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '', # e.g., '-I/usr/include/other'
);
