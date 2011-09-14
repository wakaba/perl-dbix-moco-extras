package DBIx::MoCo::TableExtras;
use strict;
use warnings;
our $VERSION = '1.0';

our $MAX_VALUES_PER_QUERY ||= 100;

sub search_where_in_each {
    my ($class, $column, $values, $code, %args) = @_;
    for my $i (0..int($#$values / $MAX_VALUES_PER_QUERY)) {
        my $from = ($i * $MAX_VALUES_PER_QUERY);
        my $to = $from + $MAX_VALUES_PER_QUERY - 1;
        $to = $#$values if $to > $#$values;
        $class->search(
            where => {
                %{$args{where} or {}},
                $column => {-in => [@$values[$from..$to]]},
            },
        )->each($code) if $from <= $to;
    }
}

1;
