# Object Oriented in Perl:
# http://www.tutorialspoint.com/perl/perl_oo_perl.htm
# types in Perl:
# http://perldoc.perl.org/perlintro.html#Perl-variable-types

package DataEnv;
use strict;
use warnings FATAL => 'all';

# Environment for data. Specifies the set of fields retrieved from server for matching products (Querier)

sub new {
    # Usage : new DataEnv(String[] set_of_properties)
    my $class = shift;
    my $self = {
        # Address of array of properties
        _prod_props_to_display => shift
    };
    # Array of properties
    my @prod_props_to_display = @{$self->{_prod_props_to_display}};
#    print scalar(@prod_props_to_display), "\n";

    if (!( grep /code/, @prod_props_to_display)) {
        push @prod_props_to_display, "code";
    }
    if (!( grep /_id/, @prod_props_to_display)) {
        push @prod_props_to_display, "_id";
    }
    # set_of_properties: [] of properties
    $self->{_prod_props_to_display} = \@prod_props_to_display;
    bless $self, $class;
    return $self;
}
1;

