package Test::MyMoCo::Table1;
use strict;
use warnings;
use base qw(DBIx::MoCo);
use Test::MyMoCo::DataBase;
use DBIx::MoCo::ColumnsMethods;

__PACKAGE__->db_object('Test::MyMoCo::DataBase');
__PACKAGE__->table('table1');
__PACKAGE__->primary_keys(['muid']);
__PACKAGE__->unique_keys(['muid']);

__PACKAGE__->datetime_columns(qw(created_on));
__PACKAGE__->fixed_length_columns(qw(fixed1));
__PACKAGE__->fixed_length_utf8_columns(qw(fixed2));
__PACKAGE__->struct_columns(qw(struct));

1;
