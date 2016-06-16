#!/usr/bin/perl
package Vertix;

sub new
{
    my $class = shift;
    my $self = {
        _id => shift,
        _label  => shift, 
        _degreeHash => {},
        _degree => 0,
        
    };
    bless $self, $class;
    return $self;
}

##############
#addEdge
#neccessary to keep track of each edge of a vertix, to later check if the edges are the same for two vertices (comparison for edges at the pruning of the n X m matrix)
##############
sub addEdge
{
    my( $self ) = shift;
    if (@_) {
        my $edgeLabel = shift;
        $self->{_degree} += 1;
        if ($self->{_degreeHash}{$edgeLabel}) {
            $self->{_degreeHash}{$edgeLabel} += 1;
        }else
        {
            $self->{_degreeHash}{$edgeLabel} = 1;
        }
    }
}

## only getter methods below
sub degreeHash
{
   my( $self ) = shift;
   return $self->{_degreeHash}; 
}
sub degree
{
    my( $self ) = shift;
    return $self->{_degree};
}
sub label
{
    my( $self ) = shift;
    return $self->{_label};
}
sub id
{
   my( $self ) = shift;
   return $self->{_id};
}

1;