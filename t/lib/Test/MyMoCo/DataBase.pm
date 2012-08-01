package Test::MyMoCo::DataBase;
use strict;
use warnings;
use base qw(DBIx::MoCo::DataBase);
use Test::mysqld;

my $dbname = 'mocox_test';

our $mysqld = eval {
    Test::mysqld->new(
        mysqld => $ENV{MYSQLD} || Test::mysqld::_find_program(qw/mysqld bin libexec sbin/),
        mysql_install_db => $ENV{MYSQL_INSTALL_DB} || Test::mysqld::_find_program(qw/mysql_install_db bin scripts/) . ($^O eq 'darwin' ? '' : ' '),
        my_cnf => { 'skip-networking' => '' },
    );
} or die $Test::mysqld::errstr;

{
    my $dbh = DBI->connect($mysqld->dsn(dbname => 'mysql')) or die $DBI::errstr;
    $dbh->do(sprintf 'CREATE DATABASE `%s`', $dbname) or die $DBI::errstr;
}

{
    my $dbh = DBI->connect($mysqld->dsn(dbname => $dbname)) or die $DBI::errstr;
    $dbh->do(q{

      CREATE TABLE table1 (
        muid BIGINT UNSIGNED NOT NULL,
        fixed1 BINARY(31) NOT NULL,
        fixed2 BINARY(31) NOT NULL,
        struct BLOB,
        created_on TIMESTAMP NOT NULL DEFAULT 0,
        PRIMARY KEY (muid)
      ) DEFAULT CHARSET=BINARY;

    }) or die $DBI::errstr;
}

#__PACKAGE__->username(...);
#__PACKAGE__->password(...);
__PACKAGE__->dsn($mysqld->dsn(dbname => $dbname));

1;
