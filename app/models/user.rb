class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }


  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email address" }


  validates :password, presence: true, length: { minimum: 8 }, format: {  with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+\z/, 
    message: "must include at least one uppercase letter, one lowercase letter, one digit, and one special character" 
  }

  validates :phone_no, presence: true, format: { with: /\A[6-9]\d{9}\z/,  message: "must be a valid Indian phone number (10 digits, starting with 6, 7, 8, or 9)" }
end
