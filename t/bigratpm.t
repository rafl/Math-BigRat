#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  chdir 't' if -d 't';
  unshift @INC, '../lib'; # for running manually
  plan tests => 3;
  }

# testing of Math::BigRat

use Math::BigRat;

my ($x,$y,$z);

$x = Math::BigRat->new(1234);
ok ($x,1234);
$x = Math::BigRat->new('1234/1');
ok ($x,1234);
$x = Math::BigRat->new('1234/2');
ok ($x,617);

#my $x = Math::BigRat->new('7/5'); $x *= '3/2'; $x -= '0.1';
#ok ($x,'2');

# done

1;

