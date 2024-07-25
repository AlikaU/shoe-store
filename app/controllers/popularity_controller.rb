class PopularityController < ApplicationController
  include ActionController::Live

  def index
    # todo: is it wasteful to create a new instance every time? alternatives?
    popularity_report = PopularityCalculator.new.calculate
    render json: popularity_report
  end
end
