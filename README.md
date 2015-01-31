# Bibler

A RESTful web service for common English translations of the Christian bible.

# Developer Quick Start

Bibler is a Rails app for the Ruby 2.2+ compatible runtimes, built with AngularJS and Twitter Bootstrap.

	bundle install # Install ruby dependencies.
	# Edit your config/database.yml to point to a valid PostgreSQL database. (No SQLite, sorry.)
    rails db:migrate # Generate a SQLite3 database and apply schema migrations.
    rails db:seed # Load bible data. Will take a while!
    rails s # Run the server.
    open localhost:3000 # Use it!

# Updating The Static Sitemap

	# Edit your config/sitemap.rb to point to your own URL.
    rake sitemap:refresh # Only do this with a fully-loaded database! It'll take a while.


# Attribution

Author: Preston Lee

Data provided by the scrollmapper/bible_databases project: https://github.com/scrollmapper/bible_databases