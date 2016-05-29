package Querier;
use strict;
use warnings FATAL => 'all';
use MongoDB;    # https://metacpan.org/pod/MongoDB pour un exemple

sub new
{
    # Usage : new Querier(DataEnv data_env, boolean verbose)
    my $class = shift;
    my $self = {
        # Object DataEnv
        _data_env => shift,
        _verbose => shift,
        _pongo => 1
    };

    bless $self, $class;
    return $self;
}

sub fetch {
    # Fecthes all products matching a single criterium
    #  :param prop: criterium key
    #  :param val: criterium value
    #  :return: list of Product
    my ( $self, $prop , $val) = @_;
    $self->{_prop} = $prop if defined($prop);
    $self->{_val} = $val if defined($val);
    my $data_env = $self->{_data_env};

    print "self = $self";
    print "\n";
    print "prop = $self->{_prop}";
    print "\n";
    print "val = $self->{_val}";
    print "\n";

    my @products_fetched = ();
    # preparing projection fields for the find request (no _id)
    my %fields_projection = ();
    foreach $a_prop ($data_env->{_prod_props_to_display}) {
        push %fields_projection, {$a_prop => 1};
    }
    # id, code and categories always retrieved (used as filter criteria = projection)
    push %fields_projection, {"_id" => 1};
    push %fields_projection, {"code" => 1};
    push %fields_projection, {"categories_tags" => 1};

    if ($self->{_verbose}) {
        print ".. fetching product details with { $self->{_prop}: $self->{_val} } ..\n";
    }
}

sub connect {
    # Connection to the OFF-Product database
    # todo: review since hard-coded!
    my( $self ) = @_;
    my $verbose = $self->{_verbose};

    if ($verbose == 1) {
        print '.. connecting to server MongoClient ("127.0.0.1", 27017)\n';
    }
    $self->{_pongo} = MongoDB->connect('mongodb://127.0.0.1:27017');

    if ($verbose == 1) {
        print ".. connecting to OPENFOODFACTS database and getting PRODUCTS collection\n";
    }
    my $coll_products = $self->{_pongo}->ns('off-fr.products'); # database off-fr, collection products
    my $nb_prods = $coll_products->find()->count();
    if ($verbose == 1) {
        print "${nb_prods} products are referenced\n";
    }
}

sub disconnect {
    # Closing connection
    my( $self ) = @_;
    my $verbose = $self->{_verbose};

    if ($verbose == 1) {
        print ".. closing connection\n";
    }
    $self->{_pongo}->disconnect();
    if ($verbose == 1) {
        print "done.\n";
    }
}
1;