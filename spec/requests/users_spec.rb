require 'rails_helper'

RSpec.describe "User API", type: :request do
  let(:user) { create(:user, password: "Test@123", password_confirmation: "Test@123") }
  let(:valid_headers) { { "Authorization" => "Bearer #{JwtService.encode({ user_id: user.id })}" } }

  describe "POST /api/v1/register" do
    let(:valid_user_params) do
      {
        name: "Akshay Katoch",
        email: "akshay@example.com",
        password: "Test@123",
        password_confirmation: "Test@123",
        phone_no: "9876543210"
      }
    end

    it "registers a user successfully" do
      post "/api/v1/register", params: { user: valid_user_params }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include("message" => "User registered successfully")
    end

    it "fails when email is already taken" do
      create(:user, email: "akshay@example.com")
      post "/api/v1/register", params: { user: valid_user_params }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "POST /api/v1/login" do
    let(:login_params) { { email: user.email, password: "Test@123" } }

    it "logs in successfully" do
      post "/api/v1/login", params: login_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("message" => "Login successful", "token" => anything)
    end

    it "fails with incorrect password" do
      post "/api/v1/login", params: { email: user.email, password: "WrongPass" }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to include("errors")
    end
  end

  describe "POST /api/v1/forgot_password" do
    it "sends an OTP successfully" do
      post "/api/v1/forgot_password", params: { email: user.email }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("message")
    end

    it "fails for non-existent user" do
      post "/api/v1/forgot_password", params: { email: "nonexistent@example.com" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("error" => "User not found")
    end
  end

  describe "POST /api/v1/reset_password" do
    let(:valid_params) { { email: user.email, otp: "123456", new_password: "NewPass@123" } }

    before do
      allow(UserService).to receive(:verify_otp_and_reset_password).and_return({ success: true, message: "Password reset successfully." })
    end

    it "resets password successfully" do
      post "/api/v1/reset_password", params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("message")
    end
  
    it "fails with invalid OTP" do
      allow(UserService).to receive(:verify_otp_and_reset_password).and_return({ success: false, error: "Invalid or expired OTP" })
      post "/api/v1/reset_password", params: valid_params.merge(otp: "wrong_otp")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include("error" => "Invalid or expired OTP")
    end
  end

 
end
