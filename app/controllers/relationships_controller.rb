class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]

    if @user
      current_user.follow @user
      redirect_to @user
    else
      flash[:danger] = t ".user_not_exist"
      redirect_to_root
    end
  end

  def destroy
    @user = Relationship.find_by(id: params[:id]).followed
    if @user.blank?
      flash[:danger] = t ".user_not_exist"
      redirect_to root_path
    else
      current_user.unfollow @user
      redirect_to @user
    end
  end
end
