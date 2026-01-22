# Bibler

A RESTful web service API for common English translations of the Christian bible. Built with Rails 7.

# Developer Quick Start

Bibler is a full API and search service for the Ruby 3.3+ compatible runtimes.

	bundle install # Install ruby dependencies.
	cp config/sitemap.rb.sample config/sitemap.rb # Set your production URL
	cp config/database.yml.sample config/database.yml # Edit, please! (Postgres only)
	git submodule init
	git submodule update

    rails db:migrate # Apply schema migrations.
    rails db:seed # Load bible data. Will take a while due to text indexing.
    rails s # Run the server.
    open localhost:3000 # Use it!

# Loading License Bibles

Translations such as the New American Standard Bible require explicit licensing. We do not provide these data files, though a template CSV is provided in the *lib/tasks/* directory. If you have permission and the licensed *bibler_nasb.csv* data file in that directory, run the following after initial seeding:

	rake bibler:nasb

# Deployment

Bibler Server is a bible study API provided as a Rails application, and is pre-built and distributed via [Docker Hub](https://hub.docker.com/r/p3000/bibler-server).

See Bibler UI for the web frontend.

# Building

Custom Bibler Server distributions can be build with Docker or compatible build systems. To build,

```docker buildx build --platform linux/arm64,linux/amd64 -t p3000/bibler-server:latest . --push```

To run it:
```
docker run -it --rm -p 8080:3000 --name bibler-server \
-e "BIBLER_SERVER_DATABASE_URL=postgresql://bibler:password@192.168.1.191:5432/bibler_development" \
-e "BIBLER_SERVER_SECRET_KEY_BASE=super_secret" \
-e "BIBLER_SERVER_MIN_THREADS=4" \
--platform linux/amd64 \
p3000/bibler-server:latest
```

# Attribution

Author: Preston Lee

Data provided by the scrollmapper/bible\_databases project: https://github.com/scrollmapper/bible_databases
