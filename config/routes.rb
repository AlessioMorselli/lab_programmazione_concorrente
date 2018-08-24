Rails.application.routes.draw do
  ### URL RESTFUL ###
  resources :groups, param: :uuid do
    resources :events, except: [:show]
    resources :memberships, only: [:index, :destroy], param: :user_id
    resources :messages, except: [:show, :new, :edit] do
      resources :attachments, only: [:destroy]
    end
    resources :invitations, only: [:show, :new, :create, :destroy], param: :url_string
  end
  resources :degrees_courses, only: [:index]
  resources :degrees, only: [:show]
  resources :users, except: [:new, :create, :show] do
    resources :events, only: [:show]
    resources :invitations, only: [:index]
  end

  ### URL NON RESTFUL ###
  get     '/signup',                                                  to: 'users#new'
  post    '/signup',                                                  to: 'users#create'

  get     '/',                                                        to: 'session#new'
  get     '/login',                                                   to: 'session#new'
  post    '/login',                                                   to: 'session#create'
  delete  '/logout',                                                  to: 'session#destroy'

  # Bacheca del gruppo
  get     '/groups/:group_uuid/messages/pinned',                      to: 'messages#pinned', as: 'group_pinned_messages'

  # Aggiunge / Toglie un messaggio dalla bacheca
  get     '/groups/:group_uuid/message/:id/pin',                      to: 'messages#pin_message', as: 'group_pin_message'
  
  # Lista di tutti gli eventi dell'utente
  get     '/users/:user_id/events',                                   to: 'events#user_index', as: 'user_events'

  # L'utente accetta l'invito ed entra nel gruppo
  get     '/groups/:group_uuid/invitations/:url_string/accept',       to: 'invitations#accept', as: 'group_accept_invitation'
  # L'utente rifiuta l'invito e non entra nel gruppo
  get     '/groups/:group_uuid/invitations/:url_string/refuse',       to: 'invitations#refuse', as: 'group_refuse_invitation'

  # Per scaricare l'allegato di un messaggio
  get     '/groups/:group_uuid/messages/:message_id/attachment/:id/download',
      to: 'messages#download_attachment', as: 'group_message_attachment_download'
  
  # Aggiunge / Rimuove il titolo di amministratore
  get     '/groups/:group_uuid/memberships/:user_id/admin',           to: 'memberships#set_admin', as: 'group_set_admin'

  # Trasferisce il titolo di super amministratore
  get     '/groups/:group_uuid/memberships/:user_id/super_admin',
      to: 'memberships#set_super_admin', as: 'group_set_super_admin' 
end
