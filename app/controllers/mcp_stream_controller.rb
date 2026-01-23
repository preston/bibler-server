# frozen_string_literal: true

# Author: Preston Lee
# MCP Stream Controller for GET requests (SSE announcement channel)
# This controller handles Server-Sent Events streaming
class McpStreamController < ApplicationController
  include ActionController::Live

  def stream
    # MCP HTTP Stream Transport: GET requests establish SSE announcement channel
    # This is a long-lived connection for server-initiated events
    session_id = request.headers['Mcp-Session-Id'] || generate_session_id
    session = Mcp::SessionManager.find_or_create_session(session_id)

    response.headers['Mcp-Session-Id'] = session.session_id
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Connection'] = 'keep-alive'
    response.headers['X-Accel-Buffering'] = 'no' # Disable nginx buffering if present

    # Send initial connection event immediately
    response.stream.write("event: connected\n")
    response.stream.write("data: {\"session_id\":\"#{session.session_id}\"}\n\n")

    # Keep connection alive with periodic keepalive messages
    # MCP spec recommends keeping this connection open for announcements
    # Use shorter keepalive interval to prevent timeouts
    begin
      loop do
        sleep 10 # Send keepalive every 10 seconds (reduced from 15)
        response.stream.write(": keepalive\n\n")
      end
    rescue ActionController::Live::ClientDisconnected
      # Client disconnected, close gracefully
      Rails.logger.info "MCP SSE client disconnected: #{session_id}"
    ensure
      response.stream.close
    end
  end

  private

  def generate_session_id
    SecureRandom.uuid
  end
end
