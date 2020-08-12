class FollowingController < ApplicationController
  before_action :logged_in_user, :find_user, only: :index

  def index
    @title = t ".following"
    @users = @user.following.page(params[:page]).per Settings.pagination.per_page
	  render "users/show_follow"
  end
end
