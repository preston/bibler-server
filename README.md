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

# MCP (Model Context Protocol) Support

The Bibler server supports the Model Context Protocol, allowing AI agents to discover and use bible research tools.

## Testing with MCP Inspector

Use the official MCP Inspector tool to test and debug the MCP server:

1. Start the Bibler server:
   ```bash
   rails s
   ```

2. In a separate terminal, run the MCP Inspector with increased timeout:
   ```bash
   MCP_SERVER_REQUEST_TIMEOUT=30000 npx @modelcontextprotocol/inspector
   ```
   
   Or use the Inspector's direct connection mode:
   ```bash
   npx @modelcontextprotocol/inspector --url http://localhost:3000/mcp
   ```

3. The Inspector UI will open at `http://localhost:6274`

4. If connecting manually in the UI:
   - **Transport**: Streamable HTTP (or HTTP Stream)
   - **URL**: `http://localhost:3000/mcp`
   - **Connection Type**: Direct
   - **No authentication required** - the server accepts requests without auth headers

5. Use the Inspector to:
   - View available tools in the Tools tab
   - Test tool calls with different parameters
   - Monitor server responses and notifications
   - Debug protocol-level issues

**Configuration Tips**:
- **IMPORTANT**: The Inspector may have a shorter default timeout than expected
- **Increase the timeout in the Inspector UI**: Click "Configuration" → "Request Timeout" → Set to at least 30000ms (30 seconds) or higher
- For direct connections, ensure CORS is properly configured (already set in this server)
- The Inspector will establish both a GET SSE connection (announcement channel) and POST requests (command channel)
- No authentication is required - the server accepts requests without auth headers

**If you experience "Request timed out" errors (-32001)**:
1. **First, increase the timeout in the Inspector UI**: 
   - Click the "Configuration" button in the sidebar
   - Find "Request Timeout" and increase it to at least 30000ms (30 seconds)
   - The default might be too short (10 seconds or less)
2. Check the Rails server logs - you should see debug messages for each request
3. Verify the server responds to both GET (SSE) and POST requests using curl:
   ```bash
   # Test POST
   curl -X POST http://localhost:3000/mcp -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"ping"}'
   
   # Test GET (SSE)
   curl -N http://localhost:3000/mcp -H "Accept: text/event-stream"
   ```
4. Check browser console (F12) for any connection or CORS errors

## Available MCP Tools

- `search_verses`: Search for verses by text query
- `get_verse`: Get a specific verse by reference
- `get_chapter`: Get all verses in a chapter
- `list_books`: List books in a bible
- `list_bibles`: List available bible translations
- `get_book_info`: Get information about a specific book
- `list_languages`: List all distinct language codes and their human-readable names

## MCP Endpoint

The MCP endpoint is available at: `POST /mcp`

For streaming responses: `GET /mcp` (SSE)

# Attribution

Author: Preston Lee

Data provided by the scrollmapper/bible\_databases project: https://github.com/scrollmapper/bible_databases
