package test::DBIx::MoCo::Query::Mapped;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->subdir('lib')->stringify;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::More tests => 1;
use DBIx::MoCo::Query::Mapped;

use_ok 'DBIx::MoCo::Query::Mapped';

1;
