# frozen_string_literal: true

# Author: Preston Lee
class AiController < ApplicationController
  def health
    configured = Ollama::Client.configured?
    render json: {
      status: configured ? 'ok' : 'unconfigured',
      ollama_configured: configured,
      base_url: ENV['BIBLER_SERVER_OLLAMA_URL']
    }
  end

  def models
    result = Ollama::Client.new.list_models
    render json: result, status: result[:error].present? ? :service_unavailable : :ok
  end

  def chat
    result = Ollama::ChatService.new.generate(
      prompt: params[:prompt].to_s,
      context: params[:context].is_a?(Hash) ? params[:context] : {},
      model: params[:model]
    )
    render json: result, status: result[:error].present? ? :unprocessable_entity : :ok
  end
end
