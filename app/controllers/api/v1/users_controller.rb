class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login, :forgot_password, :reset_password]

  def forgot_password
    result = UserService.send_otp(params[:email])
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end

  def reset_password
    user = User.find_by(id: params[:id])
    return render json: { error: "User not found" }, status: :not_found unless user

    result = UserService.verify_otp_and_reset_password(user.email, params[:otp], params[:new_password])
  
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def register
    result = UserService.register(user_params)
    render json: { message: 'User registered successfully', user: result[:user] }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  
  def login
    result = UserService.login(params[:email], params[:password])
    render json: { message: 'Login successful', user: result[:user], token: result[:token] }, status: :ok
  rescue ActionController::BadRequest => e
    render json: { errors: [e.message] }, status: :bad_request
  end

  def profile
    result = UserService.fetch_profile(current_user)
    render json: { user: result[:user] }, status: :ok
  rescue ActionController::Unauthorized => e
    render json: { errors: [e.message] }, status: :unauthorized
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone_no)
  end
end
