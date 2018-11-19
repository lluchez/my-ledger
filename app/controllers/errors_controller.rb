class ErrorsController < ApplicationController

  def not_found ; render_error(404) ; end
  def unprocessable_entity ; render_error(422) ; end
  def internal_server_error ; render_error(500) ; end

  private

  def render_error(code)
    render("errors/#{code}", :status => code)
  end
end
