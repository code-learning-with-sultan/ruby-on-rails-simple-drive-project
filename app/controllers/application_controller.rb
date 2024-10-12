class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      render json: { error: "Authorization token is required" }, status: :unauthorized
    elsif token != ENV["AUTH_TOKEN"]
      render json: { error: "Invalid Authorization token" }, status: :unauthorized
    end
  end
end
