package test::DBIx::MoCo::TableExtras;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Differences;
use List::Rubyish;

{
    package test::table::1;
    use base qw(DBIx::MoCo::TableExtras);

    sub search {
        my ($class, %args) = @_;
        if (1 == keys %{$args{where} or {}}) {
            my $col = [keys %{$args{where}}]->[0];
            my $values = $args{where}->{$col}->{-in};
            die "No value" unless @$values;
            return List::Rubyish->new([@$values]);
        }
        return List::Rubyish->new;
    }
}

sub _search_where_in_each_no_value : Test(1) {
    my @result;
    test::table::1->search_where_in_each('col1', [] => sub {
        push @result, $_;
    });
    eq_or_diff \@result, [];
}

sub _search_where_in_each_value : Test(1) {
    my @result;
    test::table::1->search_where_in_each('col1', ['value1'] => sub {
        push @result, $_;
    });
    eq_or_diff \@result, ['value1'];
}

sub _search_where_in_each_values : Test(1) {
    my @result;
    test::table::1->search_where_in_each('col1', ['value1', 'val2'] => sub {
        push @result, $_;
    });
    eq_or_diff \@result, ['value1', 'val2'];
}

sub _search_where_in_many_values : Test(1) {
    my @result;
    test::table::1->search_where_in_each('col1', [1..10000] => sub {
        push @result, $_;
    });
    eq_or_diff \@result, [1..10000];
}

__PACKAGE__->runtests;

1;
