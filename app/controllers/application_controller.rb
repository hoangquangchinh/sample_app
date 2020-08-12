class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_locale


  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.user_not_found"
    redirect_to root_url
  end

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "shared.please_log_in"
    redirect_to login_url
  end
end
