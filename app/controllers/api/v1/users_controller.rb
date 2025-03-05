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
    Rails.logger.info "Received parameters: #{params.inspect}"
    
    email = params.dig(:user, :email)
    new_password = params.dig(:user, :password)
    otp = params[:otp]
  
    Rails.logger.info "Extracted email: #{email}, OTP: #{otp}"
  
    result = UserService.verify_otp_and_reset_password(email, otp, new_password)
  
    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
  




  def register
    Rails.logger.info " Incoming parameters: #{user_params.inspect}"
    
    result = UserService.register(user_params)
    
    Rails.logger.info " Service result: #{result.inspect}"
    
    if result[:success]
      Rails.logger.info "User registered successfully: #{result[:user].inspect}"
      render json: { message: 'User registered successfully', user: result[:user] }, status: :created
    else
      Rails.logger.info " Registration failed: #{result[:error].inspect}"
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end
  



  def login
    Rails.logger.info "Attempting login for email: \#{params[:email]}"
    result = UserService.login(params[:email], params[:password])

    if result[:success]
      Rails.logger.info "Login successful for user: \#{result[:user].email}"
      render json: { message: 'Login successful', user: result[:user], token: result[:token] }, status: :ok
    else
      Rails.logger.info "Login failed: \#{result[:error]}"
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
