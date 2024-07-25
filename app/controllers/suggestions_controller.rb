class SuggestionsController < ApplicationController
  include ActionController::Live

  def index
    # todo: is it wasteful to create a new instance every time? alternatives?
    suggestion = Suggestions.new.make_suggestion
    render json: { suggestion: suggestion }
  end
end
