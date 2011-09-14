package DBIx::MoCo::ColumnsMethods;
use strict;
use warnings;
our $VERSION = '2.0';
use DateTime::Format::MySQL;
use JSON::Functions::XS qw(perl2json_bytes json_bytes2perl);
use Encode;
use Exporter::Lite;

our @EXPORT = qw(
    datetime_columns
    datetime_jst_columns
    fixed_length_columns
    fixed_length_utf8_columns
    struct_columns
);

sub datetime_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    # tz=UTC-floating
    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                deflate => sub { $_[0] ? DateTime::Format::MySQL->format_datetime(shift) : '0000-00-00 00:00:00' },
                inflate => sub { $_[0] && $_[0] ne '0000-00-00 00:00:00' && DateTime::Format::MySQL->parse_datetime(shift) },
            }
        );
    }
}

sub datetime_jst_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    # tz=UTC-floating
    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                deflate => sub {
                    if ($_[0]) {
                        my $dt = $_[0]->clone;
                        $dt->set_time_zone('UTC');
                        $dt->set_time_zone('Asia/Tokyo');
                        return DateTime::Format::MySQL->format_datetime($dt);
                    } else {
                        return '0000-00-00 00:00:00';
                    }
                },
                inflate => sub {
                    if ($_[0] && $_[0] ne '0000-00-00 00:00:00') {
                        my $dt = DateTime::Format::MySQL->parse_datetime(shift);
                        $dt->set_time_zone('Asia/Tokyo');
                        return $dt;
                    } else {
                        return undef;
                    }
                },
            }
        );
    }
}

sub fixed_length_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                inflate => sub {
                    my $s = shift;
                    $s =~ s/\x00+$//;
                    return $s;
                },
                deflate => sub { $_[0] },
            },
        );
    }
}

sub fixed_length_utf8_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach (@columns) {
        $class->inflate_column(
            $_ => {
                inflate => sub {
                    my $s = shift;
                    $s =~ s/\x00+$//;
                    return decode 'utf8', $s;
                },
                deflate => sub { encode 'utf8', $_[0] },
            },
        );
    }
}

sub struct_columns {
    my $class = shift;
    my @columns = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach (@columns) {
        my $column = $_;
        no strict 'refs';
        *{$class . "\::$column"} = sub {
            my $self = shift;
            $self->{"_struct_$column"} ||= eval { json_bytes2perl ($self->param($column) || '{}') } || {};

            if (@_ % 2 == 0) {
                while (@_) {
                    my ($n, $v) = (shift, shift);
                    $self->{"_struct_$column"}->{$n} = $v;
                }
                $self->param($column => perl2json_bytes $self->{"_struct_$column"});
                $self->save;
                return unless defined wantarray;
            }

            return $self->{"_struct_$column"}->{$_[0]};
        }
    }
}

1;
