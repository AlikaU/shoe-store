class PopularityController < ApplicationController
  include ActionController::Live

  def index
    popularity_report = PopularityCalculator.new.calculate
    render json: popularity_report
  end
end
