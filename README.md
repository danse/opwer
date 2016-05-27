#### Process overview

I search jobs by filtering all available jobs, according to two kind
of property sets:

- search properties: like the category
- job properties: like the number of proposals

If you used Upwork via the web interface, setting *search properties*
corresponds to select a category and the filters about the budget, for
example, while using *job properties* corresponds to discarding job
offers which are too old, or with too many or too few interviewed
candidates, for example

##### From the process to the configuration

Turns out that these different property sets are distinct also in the
Upwork Application Programming Interface. Thus it is natural that
search properties and job properties are the main concepts around
which this project is built.

#### Usage

    $ opwer-search search.json | my-filter

This will search for jobs using search properties described in
`search.json`, and then filter them using `my-filter`. `search.json`
is a file where keys and values correspond to [these search
parameters](https://developers.upwork.com/?lang=python#jobs_search-for-jobs).
What is `my-filter`? Read below

#### Filtering scripts

For the filtering part, since i do not want to invent a new language,
i thought that the most effective way is to just use Haskell. Opwer
provides a framework to generate a filtering script out of a pure
filtering function. This way, filtering conditions can be expressed in
a very flexible way. You don't like Haskell? Use any language to write
your filtering script. `opwer-search` will return one result per line,
so that any external script can parse them. Obviously, by writing the
script in Haskell one can reuse the types and the framework provided
by Opwer.

Note that this structure is not computationally efficient, because i
am currently more concerned about flexibility than performances.

#### Interface key

My assumption is that you will use the commands provided by Opwer
always from the same directory, where you will keep configuration
files for search and filtering scripts. That directory should also
contain a file named `upwork-key`, containing the key provided from
Upwork to you in order to use its services

#### Dependencies

This package depends on the
[`haskell-upwork`](https://github.com/danse/haskell-upwork)
library. For more info please open an issue
