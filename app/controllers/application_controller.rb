class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session  # CSRF protection is disabled for APIs
  before_action :authenticate_user

  attr_reader :current_user

  private

  def authenticate_user
    auth_header = request.headers['Authorization']
    
    if auth_header.blank?
      render json: { error: 'Authorization header missing' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last
    decoded = JwtService.decode(token)
    
    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      unless @current_user
        render json: { error: 'User not found' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
    
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  rescue JWT::ExpiredSignature
    render json: { error: 'Token has expired' }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :unauthorized
  end
end
