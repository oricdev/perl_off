#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Gui qw/:all/;
use DataEnv qw/:all/;
use Querier qw/:all/;

print "starting..\n";

my @product_props_tofetch = ("code", "generic_name", "countries_tags", "categories_tags", "nutriments", "allergens", "brands_tags", "lc", "images");
my $data_env1 = new DataEnv(@product_props_tofetch);
my $gui = new Gui($data_env1);
my $querier = new Querier($data_env1, 1);

# connecting to server
$querier->connect();

print "please enter a product code ['q'uit] >";

my $prod_code = '3017620429484';


#    if ($prod_code eq '') {
#        $prod_code = '3017620429484';
#        print ".. fetching default product with code '${prod_code}'";
#    }

    # retrieve product details into object
    $products = $querier.fetch("code", $prod_code);
#    print ".. number of products found: %d" + scalar($products);

    # ...

#print "please enter a product code ['q'uit] > ";
#    $prod_code = <>;


# closing connection
$querier->disconnect();
1;
