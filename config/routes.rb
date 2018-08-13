Rails.application.routes.draw do
  ### URL RESTFUL ###
  resources :groups, param: :uuid do
    resources :events, except: [:show]
    resources :memberships, only: [:index, :destroy], param: :user_id
    resources :messages, except: [:show, :new, :edit]
    resources :invitations, only: [:show, :new, :create, :destroy]
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
  
  # Lista di tutti gli eventi dell'utente
  get     '/users/:user_id/events',                               to: 'events#user_index', as: 'user_events'

  # L'utente accetta l'invito ed entra nel gruppo
  get  '/groups/:group_uuid/invitations/:id/accept',      to: 'invitations#accept', as: 'group_accept_invitation'
  # L'utente rifiuta l'invito e non entra nel gruppo
  get  '/groups/:group_uuid/invitations/:id/refuse',      to: 'invitations#refuse', as: 'group_refuse_invitation'
end
