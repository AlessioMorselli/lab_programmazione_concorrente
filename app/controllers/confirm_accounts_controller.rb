class ConfirmAccountsController < ApplicationController
    before_action :set_user

    # GET edit_confirm_account_path(user.confirm_token, email: user.email)
    def edit
        if @user && !@user.confirmed? && @user.authenticated?(:confirm, params[:id])
            @user.activate
            log_in @user
            flash[:success] = "Account attivato!"
            redirect_to groups_path
        else
            flash[:danger] = "Link di attivazione non valido"
            redirect_to landing_path
        end
    end

    private
    def set_user
        @user = User.find_by(email: params[:email])
    end
end