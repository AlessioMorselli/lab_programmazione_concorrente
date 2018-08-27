module SessionHelper
    # Esegue il log in dell'utente passato
    def log_in(user)
        session[:user_id] = user.id
    end

    # Restituisce l'utente attualmente loggato
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find(user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find(user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # Restituisce true se vi è un utente loggato, false altrimenti
    def logged_in?
        !current_user.nil?
    end

    # Elimina le informazioni sull'utente loggato
    def log_out
        session.delete(:user_id)
        @current_user = nil
    end

    # Memorizza l'utente in una sessione permanente
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # Cancella la sessione permanente memorizzata in precedenza
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Memorizza l'ultimo messaggio letto da un utente, in modo da caricare nel gruppo solo i messaggi nuovi
    def set_last_message_read(group, time)
        cookies.permanent[create_last_message_key(current_user, group)] = time
    end

    # Restituisce il DateTime dell'ultimo messaggio letto
    def get_last_message_read(group)
        cookies.permanent[create_last_message_key(current_user, group)].to_datetime
    end

    # Crea la chiave per il cookie del last message read
    def create_last_message_key(user, group)
        user.id.to_s + group.uuid
    end

    # Verifica che un utente sia effettivamente loggato
    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = "Per compiere quest'azione è necessario effettuare login"
            redirect_to login_path
        end
    end

    # Friendly forwarding
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end

    # Memorizzo l'URL richiesta: in questo modo, posso fare una friendly forwarding
    def store_location
        session[:forwarding_url] = request.original_fullpath if request.get?
    end

    # Verifica che l'utente loggato sia effettivamente il bersaglio dell'azione
    # Vogliamo impedire che un altro utente modifichi senza permessi informazioni di utenti diversi
    # tramite url create ad hoc
    def correct_user(id)
        @user = User.find(id)
        unless current_user == @user
            flash[:danger] = "Azione non autorizzata"
            redirect_to groups_path
        end
    end

    # Verifica che l'utente loggato sia un membro del gruppo
    def is_member_in(group)
        unless group.members.include? current_user
            flash[:danger] = "Devi essere un membro per accedere ad gruppo e alle sue informazioni"
            redirect_to groups_path
        end
    end

    # Verifica che l'utente loggato sia un amministratore del gruppo
    def is_admin_in(group)
        unless group.admins.include? current_user
            flash[:danger] = "Devi essere un amministratore per eseguire questa azione"
            redirect_to group_path(uuid: group.uuid)
        end
    end

    # Verifica che l'utente loggato sia il fondatore del gruppo
    def is_super_admin_in(group)
        unless group.super_admin == current_user
            flash[:danger] = "Devi essere il fondatore per eseguire questa azione"
            redirect_to group_path(uuid: group.uuid)
        end
    end
end
