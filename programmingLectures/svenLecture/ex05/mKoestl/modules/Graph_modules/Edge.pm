#!/usr/bin/perl
package Edge;

sub new
{
    my $class = shift;
    my $self = {
        _label  => shift, 
        _startVertix => shift,
        _endVertix  => shift,
        
    };
    bless $self, $class;
    return $self;
}
sub label
{
    my( $self ) = shift;
    return $self->{_label};
}
sub startVertix
{
    my( $self ) = shift;
    return $self->{_startVertix};
}
sub endVertix
{
    my( $self ) = shift;
    return $self->{_endVertix};
}
1;