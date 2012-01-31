Timed Specs
=============

  A Rspec formatter built upon the default DocumentationFormatter which shows the time taken for each example along with the other information shown by the DocumentationFormatter. You also have the option to list the slowest 'n' examples at the end.
  

Installation
-----------

    gem install timed_specs
    
    gem 'timed_specs'


Usage
-----

    bundle exec rspec -f TimedSpecs spec/
    

Or, even easier, add this to your .rspec file:

    require 'github/markup'
    


Testing
-------

To run the tests:

    $ bundle exec rspec spec/
