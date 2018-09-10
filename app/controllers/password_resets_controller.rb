class PasswordResetsController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :is_valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  # GET new_password_reset_path
  def new
    # TODO: metti il template corrispondente
    render file: "app/views/login_page"
  end

  # POST password_resets_path
  def create
    @user = User.find_by_email(params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      
      flash[:info] = "Abbiamo inviato una mail contenente la procedura per resettare la tua password."
      redirect_to landing_path
    else
      flash.now[:danger] = "Indirizzo email non trovato"
      # TODO: metti il template corrispondente
      render file: "app/views/login_page"
    end
  end

  # GET edit_password_reset_path(user.password_token, email: user.email)
  def edit
    # TODO: metti il template corrispondente
    render file: "app/views/login_page"
  end

  # PUT/PATCH password_reset_path(user.password_token, email: user.email)
  def update
    if @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "La tua password è stata aggiornata! Cerca di non dimenticarla stavolta!"
      redirect_to groups_path
    else
      # TODO: metti il template corrispondente
      render file: "app/views/login_page"
    end
  end

  private
  def set_user
    @user = User.find_by_email(params[:email])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def is_valid_user
    unless @user && @user.confirmed? && @user.authenticated?(:reset, params[:id])
      flash[:danger] = "Errore durante il reset della password"
      redirect_to landing_path
    end
  end

  # Controlla che il reset sia ancora valido
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Il link di reset è scaduto! Se vuoi ancora resettare la password, inviane un'altra!"
      redirect_to new_password_reset_path
    end
  end
end
