package Algorithm::SetCovering;

use strict;
use warnings;
use Log::Log4perl qw(:easy);

our $VERSION = '0.01';

##################################################
sub new {
##################################################
    my($class, @options) = @_;

    my %options = @options;

    die "No value given for mandatory parameter 'columns'"
        unless exists $options{columns};

    my $self = {
        mode     => "brute_force",
        @options,
        rows     => [],
        prepared => 0,
        combos   => [],
    };

    bless $self, $class;
}

##############################################
sub add_row {
##############################################
    my($self, @columns) = @_;

    if($self->{columns} != scalar @columns) {
        die "add_row expects $self->{columns} columns" .
            "but received " . scalar @columns . "\n";
    }
  
    DEBUG "Adding row @columns";

    push @{$self->{rows}}, [@columns];

    $self->{prepared} = 0;
}

##############################################
sub row {
##############################################
    my($self, $idx) = @_;

    return @{$self->{rows}->[$idx]};
}

##############################################
sub min_row_set {
##############################################
    my($self, @columns_to_cover) = @_;

    $self->prepare() unless $self->{prepared};

    COMBO:
    for my $combo (@{$self->{combos}}) {

        for(my $idx = 0; $idx < @columns_to_cover; $idx++) {
            # Check if the combo covers it, [0] is a ref
            # to a hash for quick lookups.
            next unless $columns_to_cover[$idx];
            next COMBO unless $combo->[0]->[$idx];
        }
            # We found a minimal set, return all of its elements 
        return @{$combo->[1]};
    }

        # Can't find a minimal set
    return undef;
}

##############################################
sub prepare {
##############################################
# Create data structures for fast lookups
##############################################
    my($self) = @_;
    
        # Delete old combos;
    $self->{combos} = [];

    my $nrows = scalar @{$self->{rows}};

    # Create all possible permutations of keys.
    # (TODO: To optimize, we should get rid of
    #        keys which are subsets of other 
    #        keys)
    # Sort combos ascending by the number of keys 
    # they contain, i.e. combos with fewer keys
    # come first.
    my @combos =
        sort { bitcount($a) <=> bitcount($b) }
             (1..2**$nrows-1);
    
    DEBUG "Combos are: @combos";

    # A bunch of bitmasks to easily determine
    # if a combo contains a certain key or not.
    my @masks = map { 2**$_ } (0..$nrows-1);

    for my $combo (@combos) {
            # The key values of the combo as (1,0,...)
        my @keys    = ();
        my @covered = ();

        for(my $key_idx = 0; $key_idx < @masks; $key_idx++) {
            if($combo & $masks[$key_idx]) {
                # Key combo contains the current key. Iterate
                # over all locks and store in @covered if
                # the current key opens them.
                for(0..$self->{columns}-1) {
                    $covered[$_] ||= $self->{rows}->[$key_idx]->[$_];
                }
                push @keys, $key_idx;
            }
        }

        DEBUG "Combo '@keys' covers '@covered'";

            # Push hash ref and combo fields to 'combos'
            # array
        push @{$self->{combos}}, [\@covered, \@keys];
    }

    $self->{prepared} = 1;
}

##############################################
sub bitcount {
##############################################
# Count the number of '1' bits in a number
##############################################
    my($num) = @_;

    my $count = 0;

    while ($num) {
         $count += ($num & 0x1) ;
         $num >>= 1 ;
    }

    return $count ;
}

1;

__END__

=head1 NAME

Algorithm::SetCovering - A brute-force implementation for the "set covering problem"

=head1 SYNOPSIS

    use Algorithm::SetCovering;

    my $alg = Algorithm::SetCovering->new(
        columns => 4,
        mode    => "brute_force");

    $alg->add_row(1, 0, 1, 0);
    $alg->add_row(1, 1, 0, 0);
    $alg->add_row(1, 1, 1, 0);
    $alg->add_row(0, 1, 0, 1);
    $alg->add_row(0, 0, 1, 1);

    my @to_be_opened = (@ARGV || (1, 1, 1, 1));
    
    my @set = $alg->min_row_set(@to_be_opened);
    
    print "To open (@to_be_opened), we need ",
          scalar @set, " keys:\n";

    for(@set) {
        print "$_: ", join('-', $alg->row($_)), "\n";
    }

=head1 DESCRIPTION

Consider having M keys and N locks. Every key opens one or more locks:

         | lock1 lock2 lock3 lock4
    -----+------------------------
    key1 |   x           x
    key2 |   x     x
    key3 |   x     x     x
    key4 |         x           x
    key5 |               x     x

Given an arbitrary set of locks you have to open (e.g. 2,3,4), 
the task is to find a minimal set of keys to accomplish this.
In the example above, the set [key4, key5] fulfils that condition.

The underlying problem is called "set covering problem" and
the corresponding decision problem is NP-complete.

=head1 AUTHOR

Mike Schilli, 2003, E<lt>m@perlmeister.comE<gt>

Thanks to the friendly guys on rec.puzzles, who provided me with
valuable input to analyze the problem:
Robert Israel E<lt>israel@math.ubc.caE<gt>,
Patrick Hamlyn <path@multipro.n_ocomsp_am.au>,
and "The Qurqirish Dragon".

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Mike Schilli

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
