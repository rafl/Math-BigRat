#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  chdir 't' if -d 't';
  unshift @INC, '../lib'; # for running manually
  plan tests => 14;
  }

# testing of Math::BigRat

use Math::BigRat;

my ($x,$y,$z);

$x = Math::BigRat->new(1234); 		ok ($x,1234);
$x = Math::BigRat->new('1234/1'); 	ok ($x,1234);
$x = Math::BigRat->new('1234/2'); 	ok ($x,617);

$x = Math::BigRat->new('100/1.0');	ok ($x,100);
$x = Math::BigRat->new('10.0/1.0');	ok ($x,10);
$x = Math::BigRat->new('0.1/10');	ok ($x,'1/100');
$x = Math::BigRat->new('0.1/0.1');	ok ($x,'1');
$x = Math::BigRat->new('1e2/10');	ok ($x,10);
$x = Math::BigRat->new('1e2/1e1');	ok ($x,10);

$x = Math::BigRat->new('1/4'); $y = Math::BigRat->new('1/3');
ok ($x + $y, '7/12');
ok ($x * $y, '1/12');
ok ($x / $y, '3/4');

$x = Math::BigRat->new('7/5'); $x *= '3/2'; 
ok ($x,'21/10');
$x -= '0.1';
ok ($x,'2');	# not 21/10

# done

1;

