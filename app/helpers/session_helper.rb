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
        cookies.permanent[current_user.id.to_s + group.uuid] = time
    end

    # Restituisce il DateTime dell'ultimo messaggio letto
    def get_last_message_read(group)
        cookies.permanent[current_user.id.to_s + group.uuid].to_datetime
    end
end
