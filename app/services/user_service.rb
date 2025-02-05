class UserService
 

  def self.send_otp(email)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
  
    otp = user.generate_otp 
    UserMailer.send_otp_email(user, otp).deliver_now  
  
    { success: true, message: "OTP sent to your email" }
  end
  


def self.verify_otp_and_reset_password(email, otp, new_password)
  user = User.find_by(email: email)
  return { success: false, error: "User not found" } unless user
  return { success: false, error: "Invalid or expired OTP" } unless user.valid_otp?(otp)

  if user.update(password: new_password)  
    user.clear_otp  
    UserMailer.password_reset_successful(user).deliver_now
    { success: true, message: "Password reset successfully. A confirmation email has been sent." }
  else
    { success: false, error: user.errors.full_messages.join(", ") }
  end
end






  def self.register(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      raise ActiveRecord::RecordInvalid.new(user)
    end
  end


  
 
  def self.login(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      token = JwtService.encode({ user_id: user.id })
      { success: true, user: user, token: token }
    else
      raise ActionController::BadRequest, 'Invalid email or password'
    end
  end










  def self.fetch_profile(user)
    raise ActionController::Unauthorized, 'Unauthorized' unless user
    { success: true, user: user }
  end
end