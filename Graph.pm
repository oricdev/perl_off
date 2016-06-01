package Graph;
use strict;
use warnings FATAL => 'all';
use PointRepartition qw/:all/;

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
    $mini_prod->{"y_val_real"} = $self->convert_scoreval_to_note( $product_ref->{score_nutrition} );

    push( @{$self->{data_set_ref}}, $mini_prod );
    print "x_val_real = ", $mini_prod->{"x_val_real"}, "\n";
    print "x_val_real = ", @{$self->{data_set_ref}}[0]->{"x_val_real"}, "\n";

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

        $product_other->compute_scores( $self->{product_ref} );

        $mini_prod_other->{"score_proximity"} = $product_other->{score_proximity};
        $mini_prod_other->{"score_nutrition"} = $product_other->{score_nutrition};
        $mini_prod_other->{"x_val_real"} = $product_other->{score_proximity};
        $mini_prod_other->{"y_val_real"} = $self->convert_scoreval_to_note( $product_other->{score_proximity} );

        push ( @{$self->{xaxis_others_real}}, $mini_prod_other->{"x_val_real"} );
        push ( @{$self->{yaxis_others_real}}, $mini_prod_other->{"y_val_real"} );
        push ( @{$self->{data_set_others}}, $mini_prod_other );
    }
}

sub prepare_graph {
    my ( $self ) = @_;

    my $product_ref = $self->{product_ref};
    my $product_ref_props = $product_ref->{dic_props};
    my $code_product = $product_ref_props->{"code"};

    print ".. preparing the graph itself with d3.js \n";
    my $nb_categs_ref = scalar(@{$product_ref_props->{"categories_tags"}});
    print scalar(@{$product_ref_props->{"categories_tags"}}), "\n";

#    print @{$self->{data_set_ref}}, "\n";
#    print "b0 \n";
#    my $mini_prod = $self->{data_set_ref};
#    print $mini_prod->{"x_val_real"}, "\n";
#    print "b0..1 \n";
#    print $self->{data_set_ref}->{"x_val_real"}, "\n";
#    print "b1 \n";
    print $nb_categs_ref * (@{$self->{data_set_ref}}[0]->{"x_val_real"}), "\n";
    push ( @{$self->{xaxis_prod_ref_real}}, $nb_categs_ref * @{$self->{data_set_ref}}[0]->{"x_val_real"} );
    print "a0 \n";
    push ( @{$self->{yaxis_prod_ref_real}}, @{$self->{data_set_ref}}[0]->{"y_val_real"} );
    print "c";
    my $label_prod_ref = @{$self->{data_set_ref}}[0]->{"code"};
    print "d \n";
    print $label_prod_ref, "\n";
    push ( @{$self->{label_prod_ref}}, $label_prod_ref );

    print "1 \n";
    # prepare for all other matching products
    # ..using a uniform reparition
    # todo: not sure below.. check and adapt
    my $nb_particles = scalar @{$self->{data_set_others}};
    print $nb_particles, "\n";
    my $sample = new PointRepartition( $nb_particles );

    my @all_positions = $sample->new_positions_disc_coordinates();
    print "retour \n";
    my @x = $all_positions[0];
    my $y = $all_positions[1];
    print "oki? \n";
    my $nb_items = scalar(@x);
#    print "x = ",@x," // y = ",$y," \n";
    print "x = ",@x," \n";
    my $v_x = ();
    my $v_y = ();
    print "2 \n";
    for (my $i = 0; $i < $nb_items; $i++) {
#        print $x[$i], " // ", $y[$i], "\n";
#        push ( @{$v_x}, $x[$i] );
#        push ( @{$v_y}, $y[$i] );
    }
    print "3 \n";
    for (my $j = 0; $j < (scalar @{$v_x}); $j++) {
        my $mini_prod = $self->{data_set_others}[$j];
        my $x_j = $mini_prod->{"x_val_real"};
        my $y_j = $mini_prod->{"y_val_real"};
        print "miniprod = $x_j, $y_j \n";
        # NOTE: since we display 2 graphs (1 for all points, and 1 for the coloured stripes A..E with a specific design
        # ..for the cell matching the product reference, we need to extend the x values (multiplied by the number
        # ..of categories of the product reference)
        my $x_coord = $nb_categs_ref * ($x_j - (1 / (2 * $nb_categs_ref) * (1 - @{$v_x}[$j])));
        my $y_coord = $y_j - (0.5 * (1 - @{$v_y}[$j]));
        push ( @{$self->{xaxis_others_distributed}}, $x_coord );
        push ( @{$self->{yaxis_others_distributed}}, $y_coord );
        my $code_mini_prod = $mini_prod->{"code"};
        my $url_prod = "http://fr.on..../produit/${code_mini_prod}";
        my $url_img = "http://static.on..../images/products/" + (substr $code_mini_prod, 0, 3)."/"
            .(substr $code_mini_prod, 3, 3)."/"
            .(substr $code_mini_prod, 6, 3)."/"
            .(substr $code_mini_prod, 9)."/front_"
            .$mini_prod->{"lc"}."."
            # todo: in Python are used u"front" and u"lc" ... does not compile here so try it wuithout the "u"
            .$mini_prod->{"images"}->{"front"}->{"rev"}
            .".400.jpg";
        print "img url = $url_img \n";
        my $the_label = "<div style = 'background-color: #ffffff'><a href='http://world.on..../product/"
            .$code_mini_prod."'>"
            .$code_mini_prod."/"
            .(join "/", @{$mini_prod->{"brands_tags"}})."/"
            .$mini_prod->{"generic_name"}."<br/>"
            ."<img src='".$url_img."' height = '200px' />"
            ."</a><br/></div>";
        # todo: check below if not url_others instead??
        push ( @{$self->{labels_others}}, $url_prod );
        push ( @{$self->{labels_others}}, $the_label );
        # line 304 omitted (check)
    }

    print ".. outputting in file.. \n";

    # verbosity details
    print "\n";
    print "Product ref. x / y: ", $self->{xaxis_prod_ref_real}, " / ", $self->{yaxis_prod_ref_real}, "\n";
    print "Matching products with COUNTER:\n";
    print "\t Counter(x): <hard> \n";
    print "\t x = ", $self->{xaxis_others_distributed}, "\n";
    print "\t Counter(y): <hard> \n";
    print "\t y = ", $self->{yaxis_others_distributed}, "\n";

    # ouput in HTML/file
    my $fic_name = '_graph.html';
    open( my $fh, '>', $fic_name );
    print $fh '<!DOCTYPE html>';
    print $fh '<html lang="en">';
    print $fh '  <head>';
    print $fh '    <meta charset="utf-8">';
    print $fh '    <style> /* set the CSS */';
    print $fh '      body {';
    print $fh '        font: 10px Arial;';
    print $fh '      }';

    print $fh '      .axis path,';
    print $fh '      .axis line {';
    print $fh '        fill: none;';
    print $fh '        stroke: grey;';
    print $fh '        stroke-width: 1;';
    print $fh '        shape-rendering: crispEdges;';
    print $fh '      }';

    print $fh '      div.tooltip {';
    print $fh '        position: absolute;';
    print $fh '        text-align: center;';
    print $fh '        width: 120px;';
    print $fh '        height: 120px;';
    print $fh '        padding: 2px;';
    print $fh '        font: 10px sans-serif;';
    print $fh '        background: lightsteelblue;';
    print $fh '        border: 0px;';
    print $fh '        border-radius: 8px;';
    print $fh '        pointer-events: none;';
    print $fh '      }';

    print $fh '    </style>';
    print $fh '  </head>';
    print $fh '  <body>';
    print $fh '    <!-- load the d3.js library -->';
    # todo insert locally the min.js script + ref unten
    print $fh '    <script src="http://d3js.org/d3.v3.min.js"></script>';
    print $fh '    <script>';

    print $fh '    // Set the dimensions of the canvas / graph';
    print $fh '    var margin = {top: 30, right: 30, bottom: 60, left: 50},';
    print $fh '         width = 1000 - margin.left - margin.right,';
    print $fh '        height = 600 - margin.top - margin.bottom;';

    print $fh '    var x = d3.scale.linear().range([0, width]);';
    print $fh '    var y = d3.scale.linear().range([height, 0]);';

    print $fh '    var nb_categs = ', $nb_categs_ref, ';';
    print $fh '    var nb_nutrition_grades = 5;';

    print $fh '    // Define the axes';
    print $fh '    var xAxis = d3.svg.axis().scale(x)';
    print $fh '            .orient("bottom").ticks(nb_categs)';
    print $fh '            .tickFormat(function (d) {';
    print $fh '                if (d == 0)';
    print $fh '                    return "very low";';
    print $fh '                if (d == 1)';
    print $fh '                    return "very high";';
    print $fh '                return "";';
    print $fh '            });';

    print $fh '    var yAxis = d3.svg.axis().scale(y)';
    print $fh '            .orient("left")';
    print $fh '            .ticks(nb_nutrition_grades)';
    print $fh '            .tickFormat(function (d) {';
    print $fh '                if (d == 1)';
    print $fh '                    return "E";';
    print $fh '                if (d == 2)';
    print $fh '                    return "D";';
    print $fh '                if (d == 3)';
    print $fh '                    return "C";';
    print $fh '                if (d == 4)';
    print $fh '                    return "B";';
    print $fh '                if (d == 5)';
    print $fh '                    return "A";';
    print $fh '                return "";';
    print $fh '            });';
    print $fh '';
    print $fh '    // Define the div for the tooltip';
    print $fh '    var div = d3.select("body").append("div")';
    print $fh '            .attr("class", "tooltip")';
    print $fh '            .style("opacity", 0);';
    print $fh '';
    print $fh '    // Adds the svg canvas';
    print $fh '    var svg = d3.select("body")';
    print $fh '            .append("svg")';
    print $fh '            .attr("width", width + margin.left + margin.right)';
    print $fh '            .attr("height", height + margin.top + margin.bottom)';
    print $fh '            .append("g")';
    print $fh '            .attr("transform",';
    print $fh '            "translate("" + margin.left + "","" + margin.top + "")"");';
    print $fh '    // taken from my Python project as d3_json object';
    # //    var data = [{'y': 2.7771622768200097, 'x': 0.80766060317357491, 'content': ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/4000412045244'>4000412045244 / original-grafschafter / <br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.59704344077170624, 'x': 0.1940551104474314, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3596710404360'>3596710404360 / auchan / <br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 1.6499334885035903, 'x': 0.75604056058710722, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3596710427734'>3596710427734 / auchan / P\xe2te \xe0 tartiner aux noisettes et au cacao maigre<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 4.2199308057519334, 'x': 0.88428646276646905, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3560070519309'>3560070519309 / carrefour / Muesli floconneux 5 c\xe9r\xe9ales nature Bio<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.75441786122128951, 'x': 2.5652856023047219, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3470201011278'>3470201011278 / pur-bonheur // confiserie-pinson / <br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 3.8530339744014146, 'x': 0.31687708054467156, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/8437015940137'>8437015940137 / carlota-organic // carlota / Pat\xe9 de champi\xf1\xf3n y tofu ecol\xf3gico<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.81345787219295551, 'x': 1.7299407903172954, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/4008400401621'>4008400401621 / nutella // ferrero / Nuss-Nugat-Creme<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.41384558770871049, 'x': 2.5288651265792179, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/4300175163798'>4300175163798 / k-classic / Nuss-Nougat-Creme<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 1.4643525510065794, 'x': 0.28515289286360374, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/20089566'>20089566 / nulacta / Nuss Nougat Creme<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.31233205800547925, 'x': 1.2565068561585786, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3017620401473'>3017620401473 / ferrero // nutella / Nutella<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 2.2906743552499274, 'x': 0.74182502566334907, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/3250390729341'>3250390729341 / chabrior / <br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 0.4800832855543733, 'x': 1.5598265373558347, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/27029077'>27029077 / delinut / P\xe2te \xe0 tartiner<br/><img src='http://static.openfoodfacts.org/images/products/29099849/front.3.100.jpg' /></a><br/></div>""}, {'y': 3.1979891053971263, 'x': 3.3301428866890834, 'content':  ""<div style='background-color: #ffffff'><a href='http://world.openfoodfacts.org/product/

    print $fh '    // Scale the range of the data';
    print $fh '    x.domain([0, 1]);';
    print $fh '    y.domain([0, nb_nutrition_grades]);';

    print $fh "    var data_rect = [{'v': 1, 'color': 'rgb(240,0,0)'},";
    print $fh "                     {'v': 2, 'color': 'rgb(255,1,128)'},";
    print $fh "                     {'v': 3, 'color': 'rgb(255,103,1)'},";
    print $fh "                     {'v': 4, 'color': 'rgb(255,242,0)'},";
    print $fh "                     {'v': 5, 'color': 'rgb(0,255,0)'}]";
    print $fh '    svg.selectAll("rect")';
    print $fh '         .data(data_rect)';
    print $fh "       .enter()";
    print $fh '         .append("rect")';
    print $fh '         .attr("width", width)';
    print $fh '         .attr("height", height / 5)';
    print $fh '         .attr("y", function (d) {';
    print $fh "           return (5 - d.v) * height / 5";
    print $fh "         })";
    print $fh '         .attr("fill", function (d) {"';
    print $fh "           return d.color";
    print $fh "         })";
    print $fh '         .attr("fill-opacity", .5);';

    print $fh '    // Add the scatterplot';
    print $fh '    // .. for the product reference';
    print $fh "    var data_prod_ref = [{'nutrition_grade': 1}]";
    print $fh '    svg.selectAll("ellipse")';
    print $fh '         .data( data_prod_ref )';
    print $fh '       .enter().append(""ellipse"")';
    print $fh '         .attr("cx", width * (1 - (1 / nb_categs) / 2))';
    print $fh '         .attr("cy", function (d) {';
    print $fh '           return (height * (1 - (d.nutrition_grade / nb_nutrition_grades)) + (height / nb_nutrition_grades * 0.5));';
    print $fh '         })';
    print $fh '         .attr("rx", width / nb_categs * 0.5)';
    print $fh '         .attr("ry", (height / nb_nutrition_grades) * 0.5)';
    print $fh '         .attr("fill", "#ffffff")';
    print $fh '         .attr("fill - opacity", 0.75)';
    print $fh '    // .. for all matching products';
    print $fh "    // var data_others = [{'y': 0.54715614799747869, 'x': 2.485996622008821, 'content': ";

    print $fh '    svg.selectAll("circle")';
    print $fh '         .data(data_others)';
    print $fh '       .enter().append("circle")';
    print $fh '         .attr("r", 3)';
    print $fh '         .attr("stroke", "#000080")';
    print $fh '         .attr("stroke-width", 1)';
    print $fh '         .attr("fill", "steelblue")';
    print $fh '         .attr("cx", function (d) { ';
    print $fh '           return d.x * width;';
    print $fh '         })';
    print $fh '         .attr("cy", function (d) {';
    print $fh '           return height * (1 - d.y / nb_nutrition_grades);';
    print $fh '         })';
    print $fh '         .on("mouseover", function (d) {';
    print $fh '           div.transition()';
    print $fh '              .duration(200)';
    print $fh '              .style("opacity", .85);';
    print $fh '           div.html(d.content)';
    print $fh '              .style("left", (d3.event.pageX) + "px")';
    print $fh '              .style("top", (d3.event.pageY - 28) + "px");';
    print $fh '            })';
    print $fh '            .on("mouseout", function (d) {';
    print $fh '              div.transition()';
    print $fh '                 .duration(500)';
    print $fh '                 .style("opacity", 0);';
    print $fh '            })';
    print $fh '            .on("click", function (d) {';
    print $fh '              window.open(d.url);';
    print $fh '            });';

    print $fh '    // Add the X Axis';
    print $fh '    svg.append("g")';
    print $fh '       .attr("class", "x axis")';
    print $fh '       .attr("transform", "translate(0," + height + ")")';
    print $fh '       .call(xAxis);';

    print $fh '    // Add the X-axis label';
    print $fh '    svg.append("text")';
    print $fh '       .attr("x", width * 0.5)';
    print $fh '       .attr("y", height + 30)';
    print $fh '       .attr("dy", "1em")';
    print $fh '       .style("text-anchor", "middle")';
    print $fh '       .style("font-size", "12pt")';
    print $fh '       .text("Similarity with product reference");';

    print $fh '    // Add the Y Axis';
    print $fh '    svg.append("g")';
    print $fh '       .attr("class", "y axis")';
    print $fh '       .call(yAxis);';

    print $fh '    // Add the Y-axis label';
    print $fh '    svg.append("text")';
    print $fh '       .attr("transform", "rotate(-90)")';
    print $fh '       .attr("x", -(height * 0.5))';
    print $fh '       .attr("y", -45)';
    print $fh '       .attr("dy", "1em")';
    print $fh '       .style("text-anchor", "middle")';
    print $fh '       .style("font-size", "12pt")';
    print $fh '       .text("Nutrition grade");';

    print $fh '    </script>';
    print $fh '  </body>';
    print $fh '</html>';

    close $fh;
    print ".. graph finished! .. ciao man";
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
