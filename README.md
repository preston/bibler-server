# Bibler

A RESTful web service for common English translations of the Christian bible.

# Developer Quick Start

Bibler is a Rails app for the Ruby 2.2+ compatible runtimes, built with AngularJS and Twitter Bootstrap.

	bundle install # Install ruby dependencies.
	cp config/sitemap.rb.sample config/sitemap.rb # Set your production URL
	cp config/database.yml.sample config/database.yml # Edit, please! (Postgres only)
	git submodule init
	git submodule update

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

# Deployment

Bibler is a fairly ordinary Rails application, and is pre-built and distributed via Docker images.

# Attribution

Author: Preston Lee

Data provided by the scrollmapper/bible\_databases project: https://github.com/scrollmapper/bible_databases
