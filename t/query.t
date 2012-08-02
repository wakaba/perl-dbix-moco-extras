package test::DBIx::MoCo::Query;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->subdir('lib')->stringify;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;

{
    package test::Model;
    use base qw(Test::MoreMore::Mock);
    use List::Rubyish;

    my $LastArgs;
    
    sub last_args {
        return $LastArgs;
    }
    
    sub search {
        shift;
        $LastArgs = {@_};
        require List::Rubyish;
        return List::Rubyish->new([{count => 123}]);
    }
}

sub setup : Test(setup) {
    my $self = shift;
#    $self->{fixtures} = fixtures(qw(movie dsi_user), { yaml_dir => file(__FILE__)->parent->subdir('fixtures') });
#    moco('Movie')->delete_all(
#        where => { author_dsi_id => [qw'0000000000000333 1000000000000001'] }
#    );
}

sub _use : Test(startup => 1) {
    use_ok 'DBIx::MoCo::Query';
}

sub _null : Test(3) {
    my $null = $DBIx::MoCo::Query::Null;
    isa_ok $null, 'DBIx::MoCo::Query';
    is $null->model, undef;
    ng $null->has_item;
}

sub _new : Tests(3) {
    my $query = DBIx::MoCo::Query->new(
        model => 'Hatena::UgoMemo::MoCo::Movie',
        where => {status => 'open'},
        order => 'created_on DESC',
    );

    isa_ok $query, 'DBIx::MoCo::Query';
    is $query->order, 'created_on DESC', 'order';
    is_deeply $query->where, {status => 'open'}, 'where';
}

sub reverse_order : Test(5) {
    my $query = DBIx::MoCo::Query->new(
        model => 'Hatena::UgoMemo::MoCo::Movie',
        where => {status => 'open'},
        order => 'created_on DESC',
    );
    is $query->reverse_order, 'created_on ASC';

    $query->order('created_on ASC');
    is $query->reverse_order, 'created_on DESC';

    $query->order('description ASC');
    is $query->reverse_order, 'description DESC';

    $query->order('description ASC,abc');
    is $query->reverse_order, 'description DESC, abc DESC';

    $query->order('description DESC,abc ASC');
    is $query->reverse_order, 'description ASC, abc DESC';
}

sub _count_field : Test(18) {
    for (
        [
            {},
            {
                field => 'COUNT(*) AS count',
                where => undef,
            },
        ],
        [
            {field => 'abc'},
            {
                field => 'COUNT(abc) AS count',
                where => undef,
            },
        ],
        [
            {field => 'tbl.abc'},
            {
                field => 'COUNT(*) AS count',
                where => undef,
            },
        ],
        [
            {field => 'DISTINCT abc'},
            {
                field => 'COUNT(DISTINCT abc) AS count',
                where => undef,
            },
        ],
        [
            {field => 'distinct  abc'},
            {
                field => 'COUNT(distinct  abc) AS count',
                where => undef,
            },
        ],
        [
            {field => 'DISTINCT DATE(abc)'},
            {
                field => 'COUNT(DISTINCT DATE(abc)) AS count',
                where => undef,
            },
        ],
    ) {
        my $query = DBIx::MoCo::Query->new(
            model => 'test::Model',
            %{$_->[0]},
        );
        is $query->count, 123;
        ok $query->has_item;
        eq_or_diff +test::Model->last_args, $_->[1];
    }
}

sub _bad_search : Test(1) {
    my $q = DBIx::MoCo::Query->new(model => 'test::Model');
    eval {
        $q->search(sub { });
        ng 1;
    } or do {
        ok 1;
    };
}

#sub search : Tests {
#    my $query = Hatena::UgoMemo::Query->new(
#        model => moco('Movie'),
#        where => {author_dsi_id => '00000000DEADBEEF'},
#        order => 'created_on ASC',
#    );
#    is_deeply scalar $query->search->map_muid, [1001, 1002, 1003, 1004, 1005], 'search';
#    is_deeply scalar $query->search(0,2)->map_muid, [1001, 1002], 'search';
#    is_deeply scalar $query->search(2,2)->map_muid, [1003, 1004], 'search';
#    is_deeply scalar $query->search(4,2)->map_muid, [1005], 'search';
#}

#sub reverse_search : Tests {
#    my $query = Hatena::UgoMemo::Query->new(
#        model => moco('Movie'),
#        where => {author_dsi_id => '00000000DEADBEEF'},
#        order => 'created_on ASC',
#    );
#    is_deeply scalar $query->reverse_search->map_muid, [1001, 1002, 1003, 1004, 1005], 'reverse search';
#    is_deeply scalar $query->reverse_search(0,2)->map_muid, [1001], 'reverse search';
#    is_deeply scalar $query->reverse_search(2,2)->map_muid, [1002, 1003], 'reverse search';
#    is_deeply scalar $query->reverse_search(4,2)->map_muid, [1004, 1005], 'reverse search';
#}

__PACKAGE__->runtests;

1;
