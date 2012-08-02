package DBIx::MoCo::Query::Mapped;
use strict;
use warnings;
use base qw(DBIx::MoCo::Query Class::Data::Inheritable);

__PACKAGE__->mk_classdata(map_code => sub {
    return $_;
});

sub search {
    my $self = shift;
    return scalar $self->SUPER::search(@_)->map($self->map_code);
}

sub find {
    my $self = shift;
    return $self->SUPER::search(0, 1)->map($self->map_code)->[0];
}

# XXX 件数が多いときは適当にページングさせたい
sub each {
    my $self = shift;
    $self->search->each(@_);
}

1;
