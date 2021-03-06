class SessionsController < ApplicationController
  before_action :load_params, only: :create

  def new; end

  def create
    if @user&.authenticate @session_params[:password]
      if @user.activated?
        log_in @user
        session[:remember_me] == Settings.one ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        flash[:warning] = t "account_not_activated"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t "invalid"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def load_params
    @session_params = params[:session]
    @user = User.find_by email: @session_params[:email].downcase
    return if @user

    flash.now[:danger] = t "invalid"
    render :new
  end

  def login_with_user_activated
    log_in @user
    @sessions[:remember_me] == Settings.TRUE ? remember(@user) : forget(@user)
    redirect_back_or @user
  end
end
