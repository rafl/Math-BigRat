#!/usr/bin/perl -w

package Math::BigRat;

require 5.005_02;
use strict;

use Exporter;
use Math::BigFloat;
use vars qw($VERSION @ISA $PACKAGE @EXPORT_OK $upgrade $downgrade
            $accuracy $precision $round_mode $div_scale);

@ISA = qw(Exporter Math::BigFloat);
@EXPORT_OK = qw();

$VERSION = '0.02';

use overload;				# inherit from Math::BigFloat

##############################################################################
# global constants, flags and accessory

use constant MB_NEVER_ROUND => 0x0001;

$accuracy = $precision = undef;
$round_mode = 'even';
$div_scale = 40;
$upgrade = undef;
$downgrade = undef;

my $nan = 'NaN';
my $class = 'Math::BigRat';

sub _new_from_float
  {
  # turn a single float input into a rationale (like '0.1')
  my ($self,$f) = @_;

  #print "f $f caller", join(' ',caller()),"\n";
  $self->{_d} = $f->{_m}->copy();			# mantissa
  $self->{_n} = Math::BigInt->bone();
  $self->{sign} = $self->{_d}->{sign}; $self->{_d}->{sign} = '+';
  if ($f->{_e}->{sign} eq '-')
    {
    # something like Math::BigRat->new('0.1');
    $self->{_n}->blsft($f->{_e}->copy()->babs(),10);	# 1 / 1 => 1/10
    }
  else
    {
    # something like Math::BigRat->new('10');
    $self->{_d}->blsft($f->{_e},10); 			# 1 / 1 => 10/1
    }
  #print "$self->{_d} / $self->{_n}\n";
  $self;
  }

sub new
  {
  # create a Math::BigRat
  my $class = shift;

  my ($d,$n) = shift;

  my $self = { }; bless $self,$class;
 
#  print "ref ",ref($d),"\n";
#  if (ref($d))
#    {
#  print "isa float ",$d->isa('Math::BigFloat'),"\n";
#  print "isa int ",$d->isa('Math::BigInt'),"\n";
#  print "isa rat ",$d->isa('Math::BigRat'),"\n";
#    }

  if ((ref $d) && (!$d->isa('Math::BigRat')))
    {
#    print "is ref, but not rat\n";
    if ($d->isa('Math::BigFloat'))
      {
#      print "is ref, and float\n";
      return $self->_new_from_float($d)->bnorm();
      }
    if ($d->isa('Math::BigInt'))
      {
#      print "is ref, and int\n";
      $self->{_d} = $d->{_m}->copy();			# mantissa
      $self->{_n} = Math::BigInt->bone();
      $self->{sign} = $self->{_d}->{sign}; $self->{_d}->{sign} = '+';
      return $self->bnorm();
      }
    }
  return $d->copy() if ref $d;
      
#  print "is string\n";

  # string input with / delimiter
  if ($d =~ /\//)
    {
    return Math::BigRat->bnan() if $d =~ /\/.*\//;	# 1/2/3 isn't valid
    return Math::BigRat->bnan() if $d =~ /\/$/;		# 1/ isn't valid
    ($d,$n) = split (/\//,$d);
    # try as BigFloats first
    if (($d =~ /[\.eE]/) || ($n =~ /[\.eE]/))
      {
      # one of them looks like a float 
      $self->_new_from_float(Math::BigFloat->new($d));
      # now correct $self->{_n} due to $n
      my $f = Math::BigFloat->new($n);
      if ($f->{_e}->{sign} eq '-')
        {
	# 10 / 0.1 => 100/1
        $self->{_d}->blsft($f->{_e}->copy()->babs(),10);
        }
      else
        {
        $self->{_n}->blsft($f->{_e},10); 		# 1 / 1 => 10/1
         }
      }
    else
      {
      $self->{_d} = Math::BigInt->new($d);
      $self->{_n} = Math::BigInt->new($n);
      $self->{sign} = $self->{_d}->{sign}; $self->{_d}->{sign} = '+';
      }
    return $self->bnorm();
    }

  # simple string input
  if (($d =~ /[\.eE]/))
    {
    # looks like a float
#    print "float-like string $d\n";
    $self->_new_from_float(Math::BigFloat->new($d));
    }
  else
    {
    $self->{_d} = Math::BigInt->new($d);
    $self->{_n} = Math::BigInt->bone();
    $self->{sign} = $self->{_d}->{sign}; $self->{_d}->{sign} = '+';
    }
  $self->bnorm();
  }

sub bstr
  {
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  return $x->{_d}->bstr() if $x->{_n}->is_one(); 
  return $x->{_d}->bstr() . '/' . $x->{_n}->bstr(); 
  }

sub bsstr
  {
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  return $x->{_d}->bstr() . '/' . $x->{_n}->bstr(); 
  }

sub bnorm
  {
  # reduce the number to the shortest form and remember this (so that we
  # don't reduce again)
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  # this is to prevent automatically rounding when MBI's globals are set
  $x->{_d}->{_f} = MB_NEVER_ROUND;
  $x->{_n}->{_f} = MB_NEVER_ROUND;
  # 'forget' that parts were rounded via MBI::bround() in MBF's bfround()
  $x->{_d}->{_a} = undef; $x->{_n}->{_a} = undef;
  $x->{_d}->{_p} = undef; $x->{_n}->{_p} = undef; 

  my $gcd = $x->{_d}->bgcd($x->{_n});

  if (!$gcd->is_one())
    {
    $x->{_d}->bdiv($gcd);
    $x->{_n}->bdiv($gcd);
    }
  $x;
  }

##############################################################################
# special values

sub _bnan
  {
  # used by parent class bone() to initialize number to 1
  my $self = shift;
  $self->{_d} = Math::BigInt->bzero();
  $self->{_n} = Math::BigInt->bzero();
  }

sub _binf
  {
  # used by parent class bone() to initialize number to 1
  my $self = shift;
  $self->{_d} = Math::BigInt->bzero();
  $self->{_n} = Math::BigInt->bzero();
  }

sub _bone
  {
  # used by parent class bone() to initialize number to 1
  my $self = shift;
  $self->{_d} = Math::BigInt->bone();
  $self->{_n} = Math::BigInt->bone();
  }

sub _bzero
  {
  # used by parent class bone() to initialize number to 1
  my $self = shift;
  $self->{_d} = Math::BigInt->bzero();
  $self->{_n} = Math::BigInt->bone();
  }

##############################################################################
# mul/add/div etc

sub badd
  {
  # add two rationales
  my ($self,$x,$y,$a,$p,$r) = objectify(2,@_);

  return $self->_div_inf($x,$y)
   if (($x->{sign} !~ /^[+-]$/) || ($y->{sign} !~ /^[+-]$/) || $y->is_zero());

  # x== 0 # also: or y == 1 or y == -1
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();

  # TODO: upgrade

#  # upgrade
#  return $upgrade->bdiv($x,$y,$a,$p,$r) if defined $upgrade;

  #  1   1    gcd(3,4) = 1    1*3 + 1*4    7
  #  - + -                  = --------- = --                 
  #  4   3                      4*3       12

  my $gcd = $x->{_n}->bgcd($y->{_n});

  my $aa = $x->{_n}->copy();
  my $bb = $y->{_n}->copy(); 
  if ($gcd->is_one())
    {
    $bb->bdiv($gcd); $aa->bdiv($gcd);
    }
  $x->{_d}->bmul($bb)->badd($y->{_d}->copy()->bmul($aa)); 
  $x->{_n}->bmul($y->{_n});

  $x->bnorm()->round($a,$p,$r);
  }

sub bsub
  {
  # subtract two rationales
  my ($self,$x,$y,$a,$p,$r) = objectify(2,@_);

  return $self->_div_inf($x,$y)
   if (($x->{sign} !~ /^[+-]$/) || ($y->{sign} !~ /^[+-]$/) || $y->is_zero());

  # x== 0 # also: or y == 1 or y == -1
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();

  # TODO: upgrade

#  # upgrade
#  return $upgrade->bdiv($x,$y,$a,$p,$r) if defined $upgrade;

  #  1   1    gcd(3,4) = 1    1*3 + 1*4    7
  #  - + -                  = --------- = --                 
  #  4   3                      4*3       12

  my $gcd = $x->{_n}->bgcd($y->{_n});

  my $aa = $x->{_n}->copy();
  my $bb = $y->{_n}->copy(); 
  if ($gcd->is_one())
    {
    $bb->bdiv($gcd); $aa->bdiv($gcd);
    }
  $x->{_d}->bmul($bb)->bsub($y->{_d}->copy()->bmul($aa)); 
  $x->{_n}->bmul($y->{_n});

  $x->bnorm()->round($a,$p,$r);
  }

sub bmul
  {
  # multiply two rationales
  my ($self,$x,$y,$a,$p,$r) = objectify(2,@_);

  return $self->_div_inf($x,$y)
   if (($x->{sign} !~ /^[+-]$/) || ($y->{sign} !~ /^[+-]$/) || $y->is_zero());

  # x== 0 # also: or y == 1 or y == -1
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();

  # TODO: upgrade

#  # upgrade
#  return $upgrade->bdiv($x,$y,$a,$p,$r) if defined $upgrade;

  #  1   1    2    1
  #  - * - =  -  = -
  #  4   3    12   6
  $x->{_d}->bmul($y->{_d});
  $x->{_n}->bmul($y->{_n});

  $x->bnorm()->round($a,$p,$r);
  }

sub bdiv
  {
  # (dividend: BRAT or num_str, divisor: BRAT or num_str) return
  # (BRAT,BRAT) (quo,rem) or BRAT (only rem)
  my ($self,$x,$y,$a,$p,$r) = objectify(2,@_);

  return $self->_div_inf($x,$y)
   if (($x->{sign} !~ /^[+-]$/) || ($y->{sign} !~ /^[+-]$/) || $y->is_zero());

  # x== 0 # also: or y == 1 or y == -1
  return wantarray ? ($x,$self->bzero()) : $x if $x->is_zero();

  # TODO: list context, upgrade

#  # upgrade
#  return $upgrade->bdiv($x,$y,$a,$p,$r) if defined $upgrade;

  # 1     1    1   3
  # -  /  - == - * -
  # 4     3    4   1
  $x->{_d}->bmul($y->{_n});
  $x->{_n}->bmul($y->{_d});

  $x->bnorm()->round($a,$p,$r);
  }

##############################################################################
# is_foo methods (the rest is inherited)

sub is_int
  {
  # return true if arg (BRAT or num_str) is an integer
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

## not ready yet
  return 1 if ($x->{sign} =~ /^[+-]$/); # &&	# NaN and +-inf aren't
#    $x->{_e}->{sign} eq '+';                    # 1e-1 => no integer
  0;
  }

sub is_zero
  {
  # return true if arg (BRAT or num_str) is zero
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  return 1 if $x->{sign} eq '+' && $x->{_d}->is_zero();
  0;
  }

sub is_one
  {
  # return true if arg (BRAT or num_str) is +1 or -1 if signis given
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  my $sign = shift || ''; $sign = '+' if $sign ne '-';
  return 1
   if ($x->{sign} eq $sign && $x->{_d}->is_zero() && $x->{_n}->is_one());
  0;
  }

sub is_odd
  {
  # return true if arg (BFLOAT or num_str) is odd or false if even
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  return 1 if ($x->{sign} =~ /^[+-]$/) &&		# NaN & +-inf aren't
    ($x->{_n}->is_one() && $x->{_d}->is_odd());		# x/2 is not, but 3/1
  0;
  }

sub is_even
  {
  # return true if arg (BINT or num_str) is even or false if odd
  my ($self,$x) = ref($_[0]) ? (ref($_[0]),$_[0]) : objectify(1,@_);

  return 0 if $x->{sign} !~ /^[+-]$/;			# NaN & +-inf aren't
  return 1 if ($x->{_n}->is_one()			# x/3 is never
     && $x->{_d}->is_even());				# but 4/1 is
  0;
  }

BEGIN
  {
  *objectify = \&Math::BigInt::objectify;
  }

##############################################################################
# special calc routines

sub bceil
  {
  return Math::BigRat->bnan();
  }

sub bfloor
  {
  return Math::BigRat->bnan();
  }

sub bfac
  {
  return Math::BigRat->bnan();
  }

sub bpow
  {
  return Math::BigRat->bnan();
  }

sub blog
  {
  return Math::BigRat->bnan();
  }

sub bsqrt
  {
  return Math::BigRat->bnan();
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

Math::BigRat - arbitrarily big rationales

=head1 SYNOPSIS

  use Math::BigRat;

  $x = Math::BigRat->new('3/7');

  print $x->bstr(),"\n";

=head1 DESCRIPTION

This is just a placeholder until the real thing is up and running. Watch this
space...

=head2 MATH LIBRARY

Math with the numbers is done (by default) by a module called
Math::BigInt::Calc. This is equivalent to saying:

	use Math::BigRat lib => 'Calc';

You can change this by using:

	use Math::BigRat lib => 'BitVect';

The following would first try to find Math::BigInt::Foo, then
Math::BigInt::Bar, and when this also fails, revert to Math::BigInt::Calc:

	use Math::BigRat lib => 'Foo,Math::BigInt::Bar';

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
L<http://search.cpan.org/search?mode=module&query=Math%3A%3ABigRat> may
contain more documentation and examples as well as testcases.

=head1 AUTHORS

(C) by Tels L<http://bloodgate.com/> 2001-2002. 

=cut
