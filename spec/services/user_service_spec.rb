require 'rails_helper'

RSpec.describe UserService, type: :service do
  let(:valid_params) do
    {
      name: "John Doe",
      email: "john.doe@example.com",
      password: "Password123!",
      phone_no: "9876543210"
    }
  end

  let(:invalid_params) do
    {
      name: "John123",
      email: "invalidemail.com",
      password: "short",
      phone_no: "123"
    }
  end

  describe '.register' do
    context 'when valid params are provided' do
      it 'registers a new user successfully' do
        result = UserService.register(valid_params)
        expect(result[:success]).to eq(true)
        expect(result[:user]).to be_present
        expect(result[:user].email).to eq(valid_params[:email])
      end
    end

    context 'when invalid params are provided' do
      it 'returns an error for invalid name' do
        invalid_params[:name] = 'John123'
        result = UserService.register(invalid_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to include("Name only allows letters and spaces")
      end

      it 'returns an error for invalid email format' do
        invalid_params[:email] = 'invalidemail.com'
        result = UserService.register(invalid_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to include("Email must be a valid email address")
      end

      it 'returns an error for short password' do
        invalid_params[:password] = 'short'
        result = UserService.register(invalid_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to include("Password must include at least one uppercase letter, one lowercase letter, one digit, and one special character")
      end

      it 'returns an error for invalid phone number' do
        invalid_params[:phone_no] = '123'
        result = UserService.register(invalid_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to include("Phone no must be a valid Indian phone number (10 digits, starting with 6, 7, 8, or 9)")
      end
    end
  end

  describe '.login' do
    let(:user) { create(:user, email: "john.doe@example.com", password: "Password123!") }

    context 'when correct credentials are provided' do
      it 'logs in the user successfully' do
        result = UserService.login(user.email, "Password123!")  # Pass email and password separately
        expect(result[:success]).to eq(true)
        expect(result[:user].email).to eq(user.email)
      end
    end

    context 'when incorrect credentials are provided' do
      it 'fails to log in the user with incorrect password' do
        result = UserService.login(user.email, "WrongPassword")  # Pass email and password separately
        expect(result[:success]).to eq(false)
        expect(result[:error]).to include("Invalid email or password")
      end
    end
  end

  describe '.generate_otp' do
    let(:user) { create(:user, email: "john.doe@example.com", password: "Password123!") }

    it 'generates and sends an OTP' do
      otp_result = user.generate_otp
      expect(otp_result[:otp]).to be_present
      expect(otp_result[:otp_expiry]).to be_present
    end
  end

  describe '.verify_otp' do
    let(:user) { create(:user, email: "john.doe@example.com", password: "Password123!") }

    it 'verifies the OTP successfully when correct' do
      otp_result = user.generate_otp
      result = user.valid_otp?(otp_result[:otp])
      expect(result).to eq(true)
    end

    it 'fails to verify the OTP when incorrect' do
      otp_result = user.generate_otp
      result = user.valid_otp?("incorrectotp")
      expect(result).to eq(false)
    end
  end

  describe '.clear_otp' do
    let(:user) { create(:user, email: "john.doe@example.com", password: "Password123!") }

    it 'clears the OTP' do
      otp_result = user.generate_otp
      user.clear_otp
      result = user.valid_otp?(otp_result[:otp])
      expect(result).to eq(false)
    end
  end
end
