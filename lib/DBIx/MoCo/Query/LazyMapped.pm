package DBIx::MoCo::Query::LazyMapped;
use strict;
use warnings;
use base qw(DBIx::MoCo::Query::Mapped);

sub lazy_apply {
    if (@_ > 1) {
        $_[0]->{lazy_apply} = $_[1];
    }
    return $_[0]->{lazy_apply};
}

for my $method (qw(
    search reverse_search
    group_count count
    reverse_order
    find has_item
    dup_where merge_where
    clone each
    as_sql explain
    )) {
    no strict 'refs';
    *$method = sub {
        use strict;
        my $self = shift;
        if(my $la = $self->lazy_apply) {
            $self->lazy_apply(undef);
            $la->($self, $method, @_);
        } else {
            my $super_method = "SUPER::$method";
            $self->$super_method(@_);
        }
    }
}

1;
