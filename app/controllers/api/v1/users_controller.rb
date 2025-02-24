class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login, :forgot_password, :reset_password]

  def forgot_password
    result = UserService.send_otp(params[:email])

    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def reset_password
    result = UserService.verify_otp_and_reset_password(params[:email], params[:otp], params[:new_password])

    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def register
    result = UserService.register(user_params)
    
    if result[:success]
      render json: { message: 'User registered successfully', user: result[:user] }, status: :created
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end

  def login
    result = UserService.login(params[:email], params[:password])

    if result[:success]
      render json: { message: 'Login successful', user: result[:user], token: result[:token] }, status: :ok
    else
      render json: { errors: result[:error] }, status: :unauthorized
    end
  end

  def profile
    result = UserService.fetch_profile(current_user)
    
    if result[:success]
      render json: { user: result[:user] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone_no)
  end
end
