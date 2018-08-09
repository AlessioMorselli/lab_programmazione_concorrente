Rails.application.routes.draw do
  ### URL RESTFUL ###
  resources :groups, param: :uuid do
    resources :events, except: [:show]
    resources :memberships, only: [:index, :destroy], param: :user_id
    resources :messages, except: [:show, :new, :edit]
    # Creare tre azioni diverse:
    #   - Una per accettare l'invito
    #   - Una per rifiutare l'invito
    #   - Una per cancellare l'invito (solo amministratori)
    resources :invitations, only: [:new, :create, :destroy], param: :user_id
  end
  resources :degrees_courses, only: [:index]
  resources :degrees, only: [:show]
  resources :users, except: [:new, :create, :show] do
    resources :events, only: [:show]
    resources :invitations, only: [:index]
  end

  ### URL NON RESTFUL ###
  get     '/signup',                                              to: 'users#new'
  post    '/signup',                                              to: 'users#create'

  get     '/',                                                    to: 'session#new'
  get     '/login',                                               to: 'session#new'
  post    '/login',                                               to: 'session#create'
  delete  '/logout',                                              to: 'session#destroy'

  get     '/groups/:group_uuid/messages/pinned',                  to: 'messages#pinned', as: 'group_pinned_messages'
  
  get     '/users/:user_id/events',                               to: 'events#user_index', as: 'user_events'

  # Dov'è l'azione in cui viene creato/cancellato un membro? Da inserire!
end
