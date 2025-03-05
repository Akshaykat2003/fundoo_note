# class UserService
 

#   def self.send_otp(email)
#     user = User.find_by(email: email)
#     return { success: false, error: "User not found" } unless user

#     # Generate OTP and get expiry time
#     otp_details = user.generate_otp
#     otp = otp_details[:otp]        # Extract OTP
#     otp_expiry = otp_details[:otp_expiry]  # Extract OTP expiry

#     # Ensure OTP and OTP expiry are passed to RabbitMQ separately
#     message = { 
#       email: user.email, 
#       type: 'otp_email', 
#       otp: otp, 
#       otp_expiry: otp_expiry 
#     }.to_json

#     EXCHANGE.publish(message, routing_key: 'email_notifications', persistent: true)

#     { success: true, message: "OTP request sent to RabbitMQ" }
#   end


#   def self.verify_otp_and_reset_password(email, otp, new_password)
#     user = User.find_by(email: email)
#     raise ActionController::BadRequest, "User not found" unless user
#     raise ActionController::BadRequest, "Invalid or expired OTP" unless user.valid_otp?(otp)
  
#     if user.update(password: new_password)
#       user.clear_otp  
  
#       # Publish password reset confirmation email job to RabbitMQ
#       EMAIL_QUEUE.publish({ email: user.email, type: "password_reset" }.to_json)
  
#       { success: true, message: "Password reset successfully. A confirmation email has been sent." }
#     else
#       raise ActionController::BadRequest, user.errors.full_messages.join(", ")
#     end
#   end



#   def self.register(params)
#     user = User.new(params)
#     if user.valid?
#       user.save!
#       { success: true, message: "User registered successfully", user: user }
#     else
#       { success: false, error: user.errors.full_messages.join(", ") }
#     end
#   end


  
 
#   def self.login(email, password)
#     user = User.find_by(email: email)
#     if user&.authenticate(password)
#       token = JwtService.encode({ user_id: user.id })
#       { success: true, user: user, token: token }
#     else
#       raise ActionController::BadRequest, 'Invalid email or password'
#     end
#   end



#   def self.fetch_profile(user)
#     raise ActionController::Unauthorized, 'Unauthorized' unless user
#     { success: true, user: user }
#   end
# end




class UserService
  def self.register(params)
    user = User.new(params)
    if user.save
      { success: true, message: "User registered successfully", user: user }
    else
      { success: false, error: user.errors.full_messages.join(", ") }
    end
  end



  def self.login(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      token = JwtService.encode({ user_id: user.id })
      { success: true, user: user, token: token }
    else
      { success: false, error: "Invalid email or password" }
    end
  end

  def self.fetch_profile(user)
    return { success: false, error: "Unauthorized" } unless user

    { success: true, user: user }
  end

  def self.send_otp(email)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user

    otp_details = user.generate_otp
    message = { 
      email: user.email, 
      type: 'otp_email', 
      otp: otp_details[:otp], 
      otp_expiry: otp_details[:otp_expiry] 
    }.to_json

    EXCHANGE.publish(message, routing_key: 'email_notifications', persistent: true)
    { success: true, message: "OTP request sent to RabbitMQ" }
  end

  def self.forgot_password(email)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user

    otp_details = user.generate_otp
    UserMailer.send_otp_email(user.email, otp_details[:otp]).deliver_later

    { success: true, message: "OTP sent to email" }
  end

  def self.verify_otp_and_reset_password(email, otp, new_password)
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user

    Rails.logger.info "Validating OTP for user: #{user.email}, OTP: #{otp}, Expiry: #{user.otp_expiry}"
    return { success: false, error: "Invalid or expired OTP" } unless user.valid_otp?(otp)

    Rails.logger.info "Updating password for user: #{user.email}, New Password: #{new_password.inspect}"
    if new_password.present? && user.update(password: new_password)
        user.clear_otp
        EMAIL_QUEUE.publish({ email: user.email, type: "password_reset" }.to_json) rescue Rails.logger.error "Failed to publish password reset notification to RabbitMQ"

        { success: true, message: "Password reset successfully. A confirmation email has been sent." }
    else
        Rails.logger.error "Password update failed: #{user.errors.full_messages.join(', ')}"
        { success: false, error: user.errors.full_messages.join(", ") }
    end
end

end
