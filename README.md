# Bibler

A RESTful web service for common English translations of the Christian bible.

# Developer Quick Start

Bibler is a Rails app for the Ruby 2.2+ compatible runtimes, built with AngularJS and Twitter Bootstrap.

	bundle install # Install ruby dependencies.
	cp config/secrets.yml.sample config/secrets.yml # Change your secret, please!
	cp config/database.yml.sample config/database.yml # Edit, please! (Postgres only)
	
    rails db:migrate # Apply schema migrations.
    rails db:seed # Load bible data. Will take a while due to text indexing.
    rails s # Run the server.
    open localhost:3000 # Use it!

# Updating The Static Sitemap

	# Edit your config/sitemap.rb to point to your own URL.
    # Only do this with a fully-loaded database! It'll take a while.
	rake sitemap:refresh 

# Loading License Bibles

Translations such as the New American Standard Bible require explicit licensing. We do not provide these data files, though a template CSV is provided in the *lib/tasks/* directory. If you have permission and the licensed *bibler_nasb.csv* data file in that directory, run the following after initial seeding:

	rake bibler:nasb

# Attribution

Author: Preston Lee

Data provided by the scrollmapper/bible\_databases project: https://github.com/scrollmapper/bible_databases