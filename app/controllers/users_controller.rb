class UsersController < ApplicationController
  before_action :find_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(create new show)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.is_activated.page(params[:page]).per Settings.pagination.per_page
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".flash_activate"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".flash_success"
      redirect_to @user
    else
      flash[:danger] = t "users.edit.update_failed"
      render :edit
    end
  end

  def destroy
    @user.destroy
    if @user.destroy
      flash[:success] = t ".flash_success"
    else
      flash[:danger] = t ".not_deleted_msg"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED_PARAMS
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.logged_in_user.flash_danger"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.user_not_found"
    redirect_to root_url
  end
end
