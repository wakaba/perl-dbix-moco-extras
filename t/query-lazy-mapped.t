package test::DBIx::MoCo::Query::LazyMapped;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->subdir('lib')->stringify;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::More tests => 1;
use DBIx::MoCo::Query::LazyMapped;

use_ok 'DBIx::MoCo::Query::LazyMapped';

1;
