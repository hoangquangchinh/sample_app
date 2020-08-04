class UsersController < ApplicationController
  attr_accessor :name, :email
  def show
    @user = User.find_by params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      log_in @user
      flash[:success] = t "users.new.flash_success"
      redirect_to @user
    else
      render :new
    end
  end

  private
  def user_params
    params.require(:user).permit User::PERMITTED_PARAMS
  end
end
