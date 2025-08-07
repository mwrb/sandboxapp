class WelcomeController < ApplicationController
  def index
    @offers = Services::TuiParser.call
  end
end
