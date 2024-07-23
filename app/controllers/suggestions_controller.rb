class SuggestionsController < ApplicationController
  include ActionController::Live


  def index
    suggestion = Suggestions.new.make_suggestion
    render json: { suggestion: suggestion }
  end

  # def index
  #   response.headers["Content-Type"] = "text/event-stream"
  #   response.headers["Cache-Control"] = "no-cache"
  #   response.headers["Connection"] = "keep-alive"

  #   sse = SSE.new(response.stream, event: "data")

  #   loop do
  #     sleep 10
  #     suggestion = Suggestions.new.make_suggestion
  #     sse.write("data: #{suggestion}\n\n")
  #   end
  # ensure
  #   sse.close
  # end
  # sse_thread = Thread.new do
  #   begin
  #     loop do
  #       sleep 10
  #       suggestion = Suggestions.new.make_suggestion
  #       response.stream.write("data: #{suggestion}\n\n")
  #     end
  #   rescue IOError
  #     puts "Stream closed"
  #   ensure
  #     response.stream.close
  #   end
  # end
end
