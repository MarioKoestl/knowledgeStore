#!/usr/bin/perl

package Graph;

use Edge;
use Vertix;

sub new
{
    my $class = shift;
    my $self = {
        _label  => shift,
        _vertices  => [],
        _edges => [],
        _adjMatrix => [[]],
    };
    bless $self, $class;
    return $self;

}

#################
##initAdjacencyMatrix
#creates the adjacency Matrix for the given set of vertices and edges
##########################
sub initAdjacencyMatrix
{
    my( $self ) = shift;
    for(my $i=0;$i<scalar @{$self->{_vertices}};$i++)
    {
        for(my $j=0;$j<scalar @{$self->{_vertices}};$j++)
        {
            $self->{_adjMatrix}[$i][$j] = 0;
        }
    }
    foreach my $edge (@{$self->{_edges}})
    {
        print "",$edge->startVertix,"\n";
        $self->{_adjMatrix}[$edge->startVertix][$edge->endVertix] += 1 ;
        $self->{_adjMatrix}[$edge->endVertix][$edge->startVertix] += 1 ;
    }
}
#
###########
#insertEdge
#inserts a Edge label, startVertix, endVertix into the edge list
#also adds this edge to the corresponding start Vertix, and vica vese to the end vertix
##
sub insertEdge
{
    my( $self ) = shift;
    if (@_) {
        my $label = shift;
        my $start = shift;
        my $end = shift;
        
        my $edge = new Edge($label,$start,$end);
        push(@{$self->{_edges}},$edge);
        
        ($self->getVertixById($start))->addEdge($label);
        ($self->getVertixById($end))->addEdge($label);
    } 
}
#return the vertix who corresponds to the given Id
sub getVertixById
{
    my( $self ) = shift;
    if (@_) {
        my $pos = shift ;
        return @{$self->{_vertices}}[$pos];
    }
}

##inserts a new vertix in our vertix list
sub insertVertix
{
    my( $self ) = shift;
    if (@_) # are there other arguments
    {
        my $vertix = new Vertix(shift,shift);
        push(@{$self->{_vertices}},$vertix);
    } 
}
##below are only getter methods
sub adjMatrix
{
    my( $self ) = shift;
    return $self->{_adjMatrix};
}
sub label
{
    my( $self ) = shift;
    return $self->{_label};
}
sub edges
{
    my( $self ) = shift;
    return $self->{_edges};
}
sub vertices
{
    my( $self ) = shift;
    return $self->{_vertices};
}

1;