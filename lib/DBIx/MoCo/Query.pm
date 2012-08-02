package DBIx::MoCo::Query;
use strict;
use warnings;
use base qw(Object::CachesMethod);
use Carp;

sub new {
    my $class = shift;
    return bless((ref $_[0] eq 'HASH' ? $_[0] : +{ @_ }), $class);
}

sub model {
    if (@_ > 1) { $_[0]->{model} = $_[1] }; return $_[0]->{model};
}

sub where {
    if (@_ > 1) { $_[0]->{where} = $_[1] }; return $_[0]->{where};
}

sub order {
    if (@_ > 1) { $_[0]->{order} = $_[1] }; return $_[0]->{order};
}

sub field {
    if (@_ > 1) { $_[0]->{field} = $_[1] }; return $_[0]->{field};
}

sub group {
    if (@_ > 1) { $_[0]->{group} = $_[1] }; return $_[0]->{group};
}

sub force_index {
    if (@_ > 1) { $_[0]->{force_index} = $_[1] }; return $_[0]->{force_index};
}

sub with {
    if (@_ > 1) { $_[0]->{with} = $_[1] }; return $_[0]->{with};
}

sub group_count {
    if (@_ > 1) { $_[0]->{group_count} = $_[1] }; return $_[0]->{group_count};
}

our $Null = __PACKAGE__->new;

sub is_null {
    my $self = shift;
    not %$self;
}

sub search {
    my $self = shift;
    my ($offset, $limit) = @_;
    die "Offset should not be a reference" if defined $offset and ref $offset;
    $self->model or do {
        require DBIx::MoCo::List;
        return DBIx::MoCo::List->new;
    };
    my $list = $self->model->search(
        where  => $self->dup_where,
        order  => $self->order,
        group  => $self->group,
        field  => $self->field,
        offset => $offset,
        limit  => $limit,
        with   => $self->with,
        force_index => $self->force_index,
    );
    $self->{_has_item} = 1 if $list->length;
    return $list;
}

# orderを逆に引いて，もとの順に戻して返す
# searchとは結果が異なる
sub reverse_search {
    my $self = shift;
    my ($offset, $limit, $total) = @_;
    $total  ||= $self->count;
    $offset ||= 0;
    $limit  ||= 0;

    unless ($total and $self->model) {
        require DBIx::MoCo::List;
        return DBIx::MoCo::List->new;
    }
    return $self->search($offset, $limit) unless $limit;

    # offsetを変更
    my $tpl = $total % $limit;
    unless ($tpl == 0) {
        $offset = $total - $offset - $tpl;
    } else {
        $offset = $total - $offset - $limit;
    }

    $self->model->search(
        where  => $self->dup_where,
        order  => $self->reverse_order, # orderを逆に
        group  => $self->group,
        field  => $self->field,
        offset => $offset,
        limit  => $limit,
        with   => $self->with,
        force_index => $self->force_index,
    )->reverse;                 # 最後にreverseする
}

sub _reverse_order ($) {
    my $s = shift or return undef;
    my @s = split /\s*,\s*/, $s;
    return undef if grep { not /^\s*[^\s,()]+(?:\s+(?:[Aa]|[Dd][Ee])[Ss][Cc]\s*|\s*)$/ } @s;
    return join ', ', map { s/\s+[Aa][Ss][Cc]$/ DESC/ ? $_ : s/\s+[Dd][Ee][Ss][Cc]$/ ASC/ ? $_ : $_ . ' DESC' } @s;
}

sub reverse_order {
    my $self = shift;
    my $order = $self->order or return;
    return _reverse_order $order
        or carp sprintf 'Cannot handle order "%s"', $order;
}

sub find {
    my $self = shift;
    $self->search(0, 1)->[0];
}

#本来は$self->groupがあれば常にDISTINCT $self->groupを使うべき.
#だが他への影響を考慮してgroup_countを見ている.
sub count {
    my $self = shift;
    return $self->{_count} if exists $self->{_count};
    $self->model or return 0;
    my $field = $self->group_count
        ? 'COUNT(DISTINCT ' . $self->group . ') AS count'
        : do {
            my $f = $self->field;
            if ($f and $f =~ /^(?:DISTINCT\s+)?\w+(?:\(.+\))?$/is) {
                'COUNT('.$f.') AS count';
            } else {
                'COUNT(*) AS count';
            }
        };

    $self->{_count} = $self->model->search(
        field => $field,
        where => $self->where,
    )->first->{count} || 0;
    $self->{_has_item} = $self->{_count} > 0;
    return $self->{_count};
}

sub has_item {
    my $self = shift;
    return $self->{_has_item} if exists $self->{_has_item};
    return !!$self->find; # 中で $self->{_has_item} もセットされる
}

sub merge_where {
    my ($self, @wheres) = @_;
    $self->where({ -and => [ $self->where, @wheres ] });
}

sub dup_where {
    my $self = shift;
    my $where = $self->where;
    if (ref $where eq 'HASH') {
        +{ %$where };
    } elsif (ref $where eq 'ARRAY') {
        +[ @$where ];
    } else {
        $where;
    }
}

sub clone {
    my $self = shift;
    my $class = ref $self;
    $class->new(%$self);
}

sub as_sql {
    my $self = shift;
    $self->model->db_object->_search_sql({
        table => $self->model->table,
        where => $self->dup_where,
        order => $self->order,
        group => $self->group,
        field => $self->field,
    });
}

sub explain {
    my $self = shift;
    my ($sql, @binds) = $self->as_sql;
    $sql = "EXPLAIN $sql";
    $self->model->db_object->execute($sql, \my $data, \@binds);
    $data;
}

__PACKAGE__->add_cached_methods(qw(
    count has_item
));

1;
