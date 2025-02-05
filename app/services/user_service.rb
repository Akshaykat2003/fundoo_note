class UserService
 

  def self.send_otp(email)
<<<<<<< HEAD
  user = User.find_by(email: email)
  return { success: false, error: "User not found" } unless user

  otp = user.generate_otp
  UserMailer.send_otp_email(user, otp).deliver_now  

  { success: true, message: "OTP sent to your email" }
end

=======
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
  
    otp = user.generate_otp 
    UserMailer.send_otp_email(user, otp).deliver_now  
  
    { success: true, message: "OTP sent to your email" }
  end
  
>>>>>>> user_login


def self.verify_otp_and_reset_password(email, otp, new_password)
  user = User.find_by(email: email)
  return { success: false, error: "User not found" } unless user
  return { success: false, error: "Invalid or expired OTP" } unless user.valid_otp?(otp)

  if user.update(password: new_password)  
    user.clear_otp  
    UserMailer.password_reset_successful(user).deliver_now
<<<<<<< HEAD
    { success: true, message: "Password reset successfully. A confirmation email has been sents." }
=======
    { success: true, message: "Password reset successfully. A confirmation email has been sent." }
>>>>>>> user_login
  else
    { success: false, error: user.errors.full_messages.join(", ") }
  end
end




<<<<<<< HEAD
=======


>>>>>>> user_login
  def self.register(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      raise ActiveRecord::RecordInvalid.new(user)
    end
  end

<<<<<<< HEAD
=======

  
>>>>>>> user_login
 
  def self.login(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      token = JwtService.encode({ user_id: user.id })
      { success: true, user: user, token: token }
    else
      raise ActionController::BadRequest, 'Invalid email or password'
    end
  end

<<<<<<< HEAD
j
=======









>>>>>>> user_login
  def self.fetch_profile(user)
    raise ActionController::Unauthorized, 'Unauthorized' unless user
    { success: true, user: user }
  end
end
