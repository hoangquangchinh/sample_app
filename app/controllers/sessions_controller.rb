class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    authenticate user
  end

  def remember_me user
    params[:session][:remember_me] == Settings.form.check_box ? remember(user) : forget(user)
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def remember_or_forget user
    if params[:session][:remember_me] == Settings.form.check_box
      remember user
    else
      forget user
    end
  end

  def authenticate user
    if user&.authenticate params[:session][:password]
      if user.activated?
        log_in user
        remember_me user
        redirect_back_or user
      else
        flash[:warning] = t ".warning_msg"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t ".flash_danger"
      render :new
    end
  end
end
