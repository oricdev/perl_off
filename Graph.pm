package Graph;
use strict;
use warnings FATAL => 'all';

# Handle statistics:
# - gather and prepare data to show
# - build graph

sub new {
    my $class = shift;
    my $self = {
        # stats_props: array of product properties used to build the graph
        stats_props       => shift,
        # product-ref: Product reference
        product_ref       => shift,
        # products_others: array of all other products whose scores are compared with the score of the product reference
        products_matching => shift,
        # verbose: 0/1
        verbose           => shift
    };

    # Initialize all structures for the final graph

    # x, y coordinates on the graph and label to display for the product reference
    $self->{xaxis_prod_ref_real} = ();
    $self->{yaxis_prod_ref_real} = ();
    $self->{label_prod_ref} = ();

    # x, y coordinates on the graph and label to display for all matching products
    $self->{xaxis_others_real} = ();
    $self->{yaxis_others_real} = ();
    $self->{labels_others} = ();

    # print "length is %d" % len(self.products_matching)
    # Graph uses its own data set which is a conversion of products_matching: preparation of these datasets
    $self->{data_set_ref} = ();
    $self->{data_set_others} = ();
    $self->{xaxis_others_distributed} = ();
    $self->{yaxis_others_distributed} = ();
    # todo: use this one d3 for d3.js Page! (delete this??)
    #    self.d3_json = []

    bless $self, $class;
    return $self;
}

sub show {
    my ( $self ) = @_;
    $self->prepare_data();
    $self->prepare_graph();
}

sub prepare_data {
    my ( $self ) = @_;

    if ($self->{verbose} eq 1) {
        print ".. preparing the data for the show \n";
    }

    # preparing product reference
    my $product_ref = $self->{product_ref};
    my $product_ref_props = $product_ref->{dic_props};
    my $mini_prod->{"code"} = $product_ref_props->{"code"};
    $mini_prod->{"generic_name"} = $product_ref_props->{"generic_name"};
    $mini_prod->{"brands_tags"} = $product_ref_props->{"brands_tags"};
    # todo
    $mini_prod->{"url_product"} = $product_ref_props->{"url_product"};
    # todo
    $mini_prod->{"url_img"} = $product_ref_props->{"url_img"};
    $mini_prod->{"lc"} = $product_ref_props->{"lc"};
    $mini_prod->{"images"} = $product_ref_props->{"images"};
    $mini_prod->{"score_proximity"} = $product_ref->{score_proximity};
    $mini_prod->{"score_nutrition"} = $product_ref->{score_nutrition};
    $mini_prod->{"x_val_real"} = $product_ref->{score_proximity};
    $mini_prod->{"y_val_real"} = $self->convert_scoreval_to_note($product_ref->{score_nutrition});

    push(@{$self->{data_set_ref}}, $mini_prod);

    # preparing data for all other matching products
    foreach my $product_other (@{$self->{products_matching}}) {
        my $product_other_ref_props = $product_other->{dic_props};
        my $mini_prod_other->{"code"} = $product_other_ref_props->{"code"};
        print "adding product ", $mini_prod_other->{"code"}, "\n";
        $mini_prod_other->{"generic_name"} = $product_other_ref_props->{"generic_name"};
        $mini_prod_other->{"brands_tags"} = $product_other_ref_props->{"brands_tags"};
        # todo
        $mini_prod_other->{"url_product"} = $product_other_ref_props->{"url_product"};
        # todo
        $mini_prod_other->{"url_img"} = $product_other_ref_props->{"url_img"};
        $mini_prod_other->{"lc"} = $product_other_ref_props->{"lc"};
        $mini_prod_other->{"images"} = $product_other_ref_props->{"images"};

        $product_other->compute_scores($self->{product_ref});

        $mini_prod_other->{"score_proximity"} = $product_other->{score_proximity};
        $mini_prod_other->{"score_nutrition"} = $product_other->{score_nutrition};
        $mini_prod_other->{"x_val_real"} = $product_other->{score_proximity};
        $mini_prod_other->{"y_val_real"} = $self->convert_scoreval_to_note($product_other->{score_proximity});

        push (@{$self->{xaxis_others_real}}, $mini_prod_other->{"x_val_real"});
        push (@{$self->{yaxis_others_real}}, $mini_prod_other->{"y_val_real"});
        push (@{$self->{data_set_others}}, $mini_prod_other);
    }
}

sub prepare_graph {
    my ( $self ) = @_;

    my $product_ref = $self->{product_ref};
    my $product_ref_props = $product_ref->{dic_props};
    my $code_product = $product_ref_props->{"code"};

    my $fic_name = '_graph.html';
    open(my $fh, '>', $fic_name);
    print $fh "<!doctype html>";
    print $fh '<html class="no-js" lang="fr">';
    print $fh "<head>";
    print $fh '<meta charset="utf-8" />';
    print $fh '<meta name="viewport" content="width=device-width, initial-scale=1.0" />';
    print $fh '<link rel="stylesheet" href="http://static.openfoodfacts.org/foundation/css/app.css" />';
    print $fh '<link rel="stylesheet" href="http://static.openfoodfacts.org/foundation/foundation-icons/foundation-icons.css" />';
    print $fh '<title>', $code_product, '</title>';
    print $fh '</head>';
    print $fh '<body>';
    print $fh '<h3> Product #', $code_product, '</h3>';
    print $fh '</body>';
    print $fh '</html>';
    close $fh;
}

sub convert_scoreval_to_note {
    my ( $self, $score_nutrition) = @_;
    $self->{score_nutrition} = $score_nutrition if defined( $score_nutrition );

    # todo: distinguer Eaux et Boissons des aliments solides .. ici, que aliments solides
    # ici http://fr.openfoodfacts.org/score-nutritionnel-france
    # A - Vert : jusqu'à -1
    # B - Jaune : de 0 à 2
    # C - Orange : de 3 à 10
    # D - Rose : de 11 à 18
    # E - Rouge : 19 et plus
    if ($score_nutrition < 0) {
        return 5;  # A
    } else {
        if ($score_nutrition < 3) {
            return 4;  # B
        } else {
            if ($score_nutrition < 11) {
                return 3;  # C
            } else {
                if ($score_nutrition < 19) {
                    return 2;  # D
                } else {
                    return 1;  # E
                }
            }
        }
    }
}

1;
