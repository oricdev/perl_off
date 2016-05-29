package Gui;
use strict;
use warnings FATAL => 'all';

# Gui object for displaying the properties of a Product for instance

sub new {
    # Usage : new Gui(DataEnv data_env)
    my $class = shift;
    my $self = {
        # Object DataEnv
        _data_env => shift
    };

    bless $self, $class;
    return $self;
}

sub display {
    # Usage : Gui.display(Product a_product)
    my $a_product = @_;
    # TODO
    print "TODO\n";

}
1;
