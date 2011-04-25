package test::DBIx::MoCo::ColumnsMethods;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->subdir('lib')->stringify;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MyMoCo::Table1;
use Test::More;
use DBIx::MoCo::MUID qw(create_muid);
use DateTime;

sub _datetime_columns : Test(7) {
    my $moco = Test::MyMoCo::Table1->create(muid => create_muid);
    ok !$moco->created_on;
    $moco->created_on(DateTime->new(year => 2001, month => 2, day => 3, hour => 4, minute => 5, second => 6, time_zone => 'UTC'));
    is $moco->param('created_on'), '2001-02-03 04:05:06';

    my $moco2 = Test::MyMoCo::Table1->find(muid => $moco->muid);
    is $moco2->param('created_on'), '2001-02-03 04:05:06';
    isa_ok $moco2->created_on, 'DateTime';
    is $moco2->created_on . '', '2001-02-03T04:05:06';

    $moco2->created_on(undef);
    is $moco2->param('created_on'), '0000-00-00 00:00:00';
    
    my $moco3 = Test::MyMoCo::Table1->find(muid => $moco->muid);
    ok !$moco2->created_on;
}

__PACKAGE__->runtests;

1;
