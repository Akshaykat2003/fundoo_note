class UserMailer < ApplicationMailer
  default from: 'akshaykatoch38@gmail.com' 

  def send_otp_email(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: 'Your OTP Code')
  end

  def password_reset_successful(user)
    @user = user
    mail(to:@user.email,subject:'Your password has been successfully Reset')
  end  
end
