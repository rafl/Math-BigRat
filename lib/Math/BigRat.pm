#!/usr/bin/perl -w

package Math::BigRat;

require 5.005_02;
use strict;

use Exporter;
use Math::BigFloat(1.25);
use vars qw($VERSION @ISA $PACKAGE @EXPORT_OK
            $accuracy $precision $round_mode $div_scale);

@ISA = qw(Exporter Math::BigFloat);
@EXPORT_OK = qw(bgcd);

$VERSION = 0.01;

# Globals
$accuracy = $precision = undef;
$round_mode = 'even';
$div_scale = 40;

sub new
  {
  # create a Math::BigRat
  my $class = shift;

  my ($x,$y) = shift;
  if (!ref($x))
    {
    if ($x =~ /\//)
      {
      return Math::BigInt->bnan() if $x =~ /\/.*\//;	# 1/2/3 isn't valid
      ($x,$y) = split (/\//,$x);
      my $self = { }; bless $self,$class;
      $self->{_x} = Math::BigFloat->new($x);
      $self->{_y} = Math::BigFloat->new($y);
      return $self->bnorm();
      }
    my $self = { }; bless $self,$class;
    $self->{_x} = Math::BigFloat->new($x);
    $self->{_y} = Math::BigFloat->bone();
    return $self->bnorm();
    }
  return $x->copy();
  }

sub bstr
  {
  my $self = shift;

  my $res = $self->{_x} / $self->{_y};
  return $res->bstr();
  }

sub bnorm
  {
  # reduce the number to the shortest form and remember this (so that we
  # don't reduce again)
  my $self = shift;

  }

#sub import
#  {
#  my $self = shift;
#  Math::BigInt->import(@_);
#  $self->SUPER::import(@_);                     # need it for subclasses
#  #$self->export_to_level(1,$self,@_);           # need this ?
#  }

1;

__END__

=head1 NAME

Math::BigInt::Named - Math::BigInt's that can write their own name

=head1 SYNOPSIS

  use Math::BigInt::Named;

  $x = Math::BigInt::Named->new($str);

  print $x->name(),"\n";

  print Math::BigInt::Named->from_name('one thousand two hundred fifty),"\n";

=head1 DESCRIPTION

This is a subclass of Math::BigInt and adds support for named numbers.

Fill in.

=head2 MATH LIBRARY

Math with the numbers is done (by default) by a module called
Math::BigInt::Calc. This is equivalent to saying:

	use Math::BigInt::Named lib => 'Calc';

You can change this by using:

	use Math::BigInt::Named lib => 'BitVect';

The following would first try to find Math::BigInt::Foo, then
Math::BigInt::Bar, and when this also fails, revert to Math::BigInt::Calc:

	use Math::BigInt::Named lib => 'Foo,Math::BigInt::Bar';

Calc.pm uses as internal format an array of elements of some decimal base
(usually 1e7, but this might be differen for some systems) with the least
significant digit first, while BitVect.pm uses a bit vector of base 2, most
significant bit first. Other modules might use even different means of
representing the numbers. See the respective module documentation for further
details.

=head1 BUGS

None know yet. Please see also L<Math::BigInt>.

=head1 LICENSE

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<Math::BigFloat> and L<Math::Big> as well as L<Math::BigInt::BitVect>,
L<Math::BigInt::Pari> and  L<Math::BigInt::GMP>.

The package at
L<http://search.cpan.org/search?mode=module&query=Math%3A%3ABigInt> may
contain more documentation and examples as well as testcases.

=head1 AUTHORS

(C) by Tels in late 2001. Based on work by Chris London Noll.

=cut
