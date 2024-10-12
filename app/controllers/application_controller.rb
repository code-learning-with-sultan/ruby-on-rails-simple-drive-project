class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    token = request.headers["Authorization"]&.split(" ")&.last
    render json: { error: "Unauthorized" }, status: :unauthorized unless token == ENV["AUTH_TOKEN"]
  end
end
