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
    my @prod_props_to_display = @_;
    print scalar(@prod_props_to_display);
    print "\n";

    if (!( grep /code/, @prod_props_to_display)) {
        push @prod_props_to_display, "code";
    }
    if (!( grep /_id/, @prod_props_to_display)) {
        push @prod_props_to_display, "_id";
        print "nb of items = ";
        print scalar(@prod_props_to_display);
        print "\n";
    }
    my $self = {
        # set_of_properties: [] of properties
        _prod_props_to_display => @prod_props_to_display
    };
    bless $self, $class;
    return $self;
}
1;

