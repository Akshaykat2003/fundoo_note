class Api::V1::UsersController < ApplicationController
  # User Registration
  skip_before_action :verify_authenticity_token

  def register
    user = User.new(user_params)
    if user.save
      render json: { message: 'User registered successfully', user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :phone_no)
  end
end
