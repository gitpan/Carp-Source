#!/usr/bin/env perl

use warnings;
use strict;
use Carp::Source;
use Test::More tests => 1;
use Test::Differences;


my $context = Carp::Source::get_context(__FILE__, __LINE__);

# Some comments to
# avoid getting the expected
# context into the tested context
# which would make for recursive weirdness

my $expected = <<EOCONTEXT;
context for t/01_context.t line 10:

 7: use Test::Differences;
 8: 
 9: 
10: \e[30;43mmy \$context = Carp::Source::get_context(__FILE__, __LINE__);\e[0m
11: 
12: # Some comments to
13: # avoid getting the expected
===========================================================================
EOCONTEXT

eq_or_diff $context, $expected, 'context';

