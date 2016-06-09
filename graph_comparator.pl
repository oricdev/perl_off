#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Gui qw/:all/;
use DataEnv qw/:all/;
use Querier qw/:all/;
use Product qw/:all/;
use Graph qw/:all/;

print "starting..\n";

my @product_props_tofetch = ("code", "generic_name", "countries_tags", "categories_tags", "nutriments", "allergens",
    "brands_tags", "image_front_url");
my $data_env1 = DataEnv->new( \@product_props_tofetch );
my $gui = Gui->new( $data_env1 );
my $querier = Querier->new( $data_env1, 0 );

# connecting to server
$querier->connect();

print "please enter a product code ['q'uit] > \n";
#my $prod_code = <STDIN>;
#$prod_code = chomp( $prod_code );
#while (!($prod_code eq 'q')) {
my $prod_code = '3017620429484';
#my $prod_code = '3330720251022';
#    if ($prod_code eq '') {
#        $prod_code = '3017620429484';
#        print ".. fetching default product with code '${prod_code}'";
#    }

# retrieve product details into object
my @products = $querier->fetch( "code", $prod_code );
my $nb_products = scalar( @products );

if ($nb_products == 0)
{
    print "WARNING: the product with code $prod_code could not be found! \n";
} else {
    if ($nb_products > 1) {
        print "WARNING: more than 1 product match ... choosing 1st product";
    }
    my $myProduct = pop @products;
#    my $_id_prod_ref = $myProduct->Product::get_id();
    # $myProduct is the  product reference!
    $myProduct->Product::set_as_reference( 1 );

    # fetch similar products with the same categories
    my $props_to_match = ("categories_tags");  # for the search of similar products based on this set of properties (matching criteria)
    my $products_match = $querier->find_match( $myProduct, $props_to_match );
    print ".. NUMBER of matching distinct products found: ", scalar( @{$products_match} ), "\n";

    # todo: plus tard
    my $statsProps = ("nutriments");  # for all products, extracting of these specific items for building the statistical graphs
    my $g = Graph->new( $statsProps, $myProduct, $products_match, 1 );
    $g->show();
}
# ...

#    print "please enter a product code ['q'uit] > \n";
#    $prod_code = <>;
#}

# closing connection
$querier->disconnect();

1;
