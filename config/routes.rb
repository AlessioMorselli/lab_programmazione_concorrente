Rails.application.routes.draw do
  ### URL DI DEFAULT ###
  resources :groups do
    resources :events, except: [:show]
    resources :memberships, only: [:index]
    resources :messages, except: [:show, :new, :edit]
    # Creare tre azioni diverse:
    #   - Una per accettare l'invito
    #   - Una per rifiutare l'invito
    #   - Una per cancellare l'invito (solo amministratori)
    resources :invitations, only: [:new, :create, :destroy]
  end
  resources :degree_courses, only: [:index, :show]
  resources :degrees, only: [:show]
  resources :users, except: [:new, :create, :show] do
    resources :events, only: [:index, :show]
    resources :invitations, only: [:index]
  end

  ### URL NON DI DEFAULT ###
  get     '/signup',                                              to: 'users#new'
  post    '/signup',                                              to: 'users#create'

  # TODO: devo andare a vedere come gestire la sessione coi cookies in modo
  # che un utente non debba riloggarsi ogni volta
  get     '/',                                                    to: 'sessions#new'
  get     '/login',                                               to: 'sessions#new'
  post    '/login',                                               to: 'sessions#create'
  delete  '/logout',                                              to: 'sessions#destroy'

  get     '/groups/:group_id/messages/pinned',                    to: 'messages#pinned', as: 'group_pinned_messages'

  # Dov'è l'azione in cui viene creato/cancellato un membro? Da inserire!
  # Gestire la sessione in modo più sofisticato di così!
end
