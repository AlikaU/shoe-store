class SuggestionsController < ApplicationController
  include ActionController::Live

  def index
    suggestion = Suggestions.new.make_suggestion
    render json: { suggestion: suggestion }
  end
end
