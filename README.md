# perl_off
Proof-Of-Concept for the OPENFOODFACTS project (http://openfoodfacts.org):<br />
Comparison graph of a selected product towards other more-or-less similar products.<br ∕><br />
This project is a direct transcription in Perl from the Python project <a href='https://github.com/oricdev/off_graph.git' target='blank' title='off_graph'>off_graph</a>.<br ∕>
Has been moved to "product-opener" for later integration.

<h2>Requirements</h2>
a) Install the Math::Random Perl Package available here under the "download" link:
http://search.cpan.org/~grommel/Math-Random-0.70/Random.pm

b) Start the mongod server locally from the console:
mongod --httpinterface --rest --dbpath <off_db_path>/db_produits/dump/off-fr/

c) run graph_comparator.pl (hard-coded product-code can be updated manually on line 28 of graph_comparator.pl)

d) open the generated output-file "_graph.html" in a browser

<h2>to do</h2>
* Querier->fetch() :: add fields projection
* Limit of retrieved products is set to 50 per category since limit for outputting in file reached (see Querier->fecth() {... my $_tmp_nb_max = 50;... } )
* to ,integrate from search.pl:
    ** use Perl-HTML tags instead of outputting in a file
    ** GET-parameters for product code
* images of products should refer to field "image_front_url" (not available in Mongo-Db yet?)
