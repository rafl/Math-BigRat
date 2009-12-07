#!/usr/bin/perl -w

use Test::More;
use strict;

my $tests;

BEGIN
   {
   $tests = 1;
   plan tests => $tests;
   chdir 't' if -d 't';
   use lib '../lib';
   };

SKIP:
  {
  skip("Test::Pod::Coverage 1.00 required for testing POD coverage", $tests)
    unless do {
    eval "use Test::Pod::Coverage 1.00";
    $@ ? 0 : 1;
    };

  # The first rule of isa() is: Do not talk about isa().
  my $trustme = { trustme => [ qr/^isa\z/ ] };

  pod_coverage_ok( 'Math::BigRat', $trustme, "All our BigRats are covered" );
  }

