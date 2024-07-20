class PopularityController < ApplicationController
  include ActionController::Live

  def index
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Connection"] = "keep-alive"

    loop do
      popularity_report = PopularityCalculator.new.calculate
      response.stream.write("data: #{popularity_report.to_json}\n\n")
      sleep 5
    end
  rescue IOError
    puts "Stream closed"
  ensure
    response.stream.close
  end
end
