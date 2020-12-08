package List::Linq::Enumerable;
use strict;
use warnings;

use Scalar::Util qw/looks_like_number/;

use parent qw/List::Linq::Iterator/;

sub new {
    my $self = shift;
    my $list = @_;

    my $attr = +{
        array => defined $list ? (ref $list eq 'HASH' ? [@_] : @_) : [],
        index => -1,
        item  => undef,
    };

    my $class = ref $self || $self;
    return bless $attr, $class;
}

# extension implementations
# ported from System.Linq.Enumerable in .NET 5

# All<TSource>(IEnumerable<TSource>, Func<TSource, Boolean>) -> Boolean
sub all {
    my $self      = shift;
    my $predicate = shift;

    die 'Argument Null Error : predicate'    unless $predicate;
    die 'Aegument Invalid Error : predicate' unless ref($predicate) eq 'CODE';

    while ($self->move_next) {
        local $_ = $self->current;
        unless ($predicate->()) {
            return 0;
        }
    }

    return 1;
}

# Any<TSource>(IEnumerable<TSource>) -> Boolean
sub any {
    my $self = shift;

    return $self->move_next;
}

# Any<TSource>(IEnumerable<TSource>, Func<TSource, Boolean>) -> Boolean
sub any_with {
    my $self      = shift;
    my $predicate = shift;

    die 'Argument Null Error : predicate'    unless $predicate;
    die 'Aegument Invalid Error : predicate' unless ref($predicate) eq 'CODE';

    while ($self->move_next) {
        local $_ = $self->current;
        if ($predicate->()) {
            return 1;
        }
    }

    return 0;
}

# Average<IEnumerable<Number>> -> Number
sub average {
    my $self  = shift;
    my $sum   = 0;
    my $count = 0;

    while ($self->move_next) {
        my $item = $self->current;
        if (looks_like_number($item)) {
            $sum   += $item;
            $count += 1;
        }
    }

    return $sum / $count;
}

# Average<TSource>(IEnumerable<Number>, Func<TSource, Number>) -> Number
sub average_by {
    my $self     = shift;
    my $selector = shift;

    die 'Argument Null Error : selector'    unless $selector;
    die 'Argument Invalid Error : selector' unless ref($selector) eq 'CODE';

    my $sum   = 0;
    my $count = 0;

    while ($self->move_next) {
        local $_ = $self->current;
        my $item = $selector->();

        if (looks_like_number($item)) {
            $sum   += $item;
            $count += 1;
        }
    }

    return $sum / $count;
}

# Select<TSource, TResult>(IEnumerable<TSource>, Func<TSource, TResult>) -> IEnumerable<TResult>

use List::Linq::Query::Select;

sub select {
    my $self     = shift;
    my $selector = shift;

    die 'Argument Null Error : selector'    unless $selector;
    die 'Argument Invalid Error : selector' unless ref($selector) eq 'CODE';

    return List::Linq::Query::Select->new($self, $selector);
}

# Select<TSource, TResult>(IEnumerable<TSource>, Func<TSource, Int32, TResult>) -> IEnumerable<TResult>

use List::Linq::Query::SelectIndexed;

sub select_with_index {
    my $self     = shift;
    my $selector = shift;

    die 'Argument Null Error : selector'    unless $selector;
    die 'Argument Invalid Error : selector' unless ref($selector) eq 'CODE';

    return List::Linq::Query::SelectIndexed->new($self, $selector);
}
# interface implementations

sub current {
    my $self  = shift;

    return $self->{item};
}

sub move_next {
    my $self  = shift;
    my $array = $self->{array};
    my $index = $self->{index};

    if ($index + 1 >= scalar(@$array)) {
        return 0;
    }

    $self->{index} = $index + 1;
    $self->{item}  = @{$self->{array}}[$self->{index}];

    return 1;
};



1;