require "application_system_test_case"
require "test_helper"
 
class SystemTest < ApplicationSystemTestCase
    # Test generale del sistema! Proviamo a fare un giro dell'applicazione
    def setup
        ActionMailer::Base.deliveries.clear
        @luigi = users(:luigi)
        @mario = users(:mario)
        @pirati = groups(:pirati)
        @samurai = groups(:samurai)
        @invitation = invitations(:invito_pirati)
    end

    test "should test application" do
        # Entro nel sito: landing page
        get landing_path
        assert_response :success

        # Richiedo la pagina di signup
        get signup_path
        assert_response :success

        # Mi registro al sito col nome di Peach
        assert_difference('User.count') do
            assert_difference('Student.count') do
                post signup_path, params: { user: {
                    name: "Peach",
                    password: "principessa",
                    password_confirmation: "principessa",
                    email: "princess.peach@mario.it",
                    student_attributes: {
                        degree_id: 1,
                        year: 1
                    }
                }}
            end
        end
        @peach = assigns(:user)
        assert_redirected_to landing_path

        # Aspetto la mail e confermo l'utente
        assert_equal 1, ActionMailer::Base.deliveries.size
        get edit_confirm_account_path(@peach.confirm_token, email: @peach.email)
        @peach.reload
        assert @peach.confirmed?

        # Arrivo nella lista dei gruppi
        assert is_logged_in?
        assert_redirected_to groups_path

        # Entro nel gruppo dei samurai (essendo pubblico)
        get group_path(uuid: @samurai.uuid)
        assert_response :success

        # Provo a pinnare un messaggio, senza successo
        @message = @samurai.messages.first
        patch group_pin_message_patch(group_uuid: @samurai.uuid, id: @message.id)
        assert_not @message.pinned?

        # Torno alla lista dei gruppi
        get groups_path
        assert_response :success

        # Ricevo l'invito pubblico per i pirati e quindi accetto l'invito
        get group_invitation_path(group_uuid: @pirati.uuid, url_string: @invitation.url_string)
        assert_response :success
        assert_difference('Invitation.count', 0) do
            assert_difference('Membership.count', 1) do
                post group_accept_invitation_path(group_uuid: @pirati.uuid, url_string: @invitation.url_string)
            end
        end

        # Entro nel gruppo dei pirati
        assert_redirected_to group_path(uuid: @pirati.uuid)

        # Invo un messaggio
        assert_difference('Message.count') do
            assert_difference('Attachment.count', 0) do
                post group_messages_path(group_uuid: @pirati.uuid), params: {
                    message: {
                        text: "Grazie per avermi invitata! La prinpessa è qui!"
                    },
                    attachment: nil
                }
            end
        end
        @message = assigns(:message)

        # Mi accorgo di un errore e correggo un messaggio
        patch group_message_path(group_uuid: @pirati.uuid, id: @message.id), params: {
            message: {
                text: "Grazie per avermi invitata! La principessa è qui!"
            }
        }
        @message.reload
        assert_equal "Grazie per avermi invitata! La principessa è qui!", @message.text

        # Invio un messaggio vuoto con solo un allegato
        assert_difference('Message.count') do
            assert_difference('Attachment.count') do
                post group_messages_path(group_uuid: @group.uuid), params: {
                    message: {
                        text: ""
                    },
                    attachment: fixture_file_upload('files/test_image.jpg','image/jpeg')
                }
            end
        end

        # Creo un gruppo, chimato funghi
        get new_group_path
        assert_response :success
        assert_difference('Group.count') do
            assert_difference('Membership.count') do
                post groups_path, params: { group: {
                    name: "funghi",
                    max_members: 10,
                    private: true,
                    course_id: nil
                    }
                }
            end
        end
        @funghi = assigns(:group)
      
        # Accedo al gruppo
        assert_redirected_to group_path(uuid: @funghi.uuid)

        # Creo un link d'invito privato al gruppo per Luigi
        get new_group_invitation_path(group_uuid: @funghi.uuid)
        assert_response :success
        assert_difference('Invitation.count') do
            post group_invitations_path(group_uuid: @funghi.uuid), params: { invitation: {
                group_id: @funghi.id,
                user_id: @luigi.id
                }
            }
        end
        @invito_luigi = assigns(:invitation)
        assert_redirected_to group_path(uuid: @funghi.uuid)
        assert_equal 2, ActionMailer::Base.deliveries.size

        # Invio un messaggio e lo pinno
        assert_difference('Message.count') do
            assert_difference('Attachment.count', 0) do
                post group_messages_path(group_uuid: @pirati.uuid), params: {
                    message: {
                        text: "Benvenuti nel Regno dei Funghi!"
                    },
                    attachment: fixture_file_upload('files/test_image.jpg','image/jpeg')
                }
            end
        end
        @messaggio_peach = assigns(:message)
        @allegato_peach = assigns(:attachment)
        patch group_pin_message_patch(group_uuid: @funghi.uuid, id: @message.id)
        assert @message.pinned?

        # Creo anche un nuovo evento
        get new_group_event_path(group_uuid: @funghi.uuid)
        assert_response :success
        assert_difference('Event.count') do
            post group_events_path(group_uuid: @funghi.uuid), params: { event: {
                start_time: DateTime.now + 1.hours,
                end_time: DateTime.now + 5.hours,
                name: "Studio Piano contro Bowser",
                place: "Castello di Peach",
                description: "Riunione per studiare un modo per sconfiggere Bowser",
                group_id: @funghi.id
                }
            }
        end
        @event = assigns(:event)
         
        assert_redirected_to group_events_path(group_uuid: @funghi.uuid)

        # Modifico l'evento e posticipo l'ora di inizio di un'ora
        patch group_event_path(group_uuid: @funghi.uuid, id: @event.id), params: {
            event: { start_time: DateTime.now + 2.hours }
        }
    
        assert_redirected_to group_events_path(group_uuid: @funghi.uuid)
        @event.reload
        assert_equal DateTime.now + 2.hours, @event.start_time

        # Creo un altro link di invito privato a Mario
        get new_group_invitation_path(group_uuid: @funghi.uuid)
        assert_response :success
        assert_difference('Invitation.count') do
            post group_invitations_path(group_uuid: @funghi.uuid), params: { invitation: {
                group_id: @funghi.id,
                user_id: @mario.id
                }
            }
        end
        @invito_mario = assigns(:invitation)
        assert_redirected_to group_path(uuid: @funghi.uuid)
        assert_equal 3, ActionMailer::Base.deliveries.size

        # Faccio log out
        get logout_path


        # Faccio log in con Luigi
        log_in_as @luigi

        # Accetto l'invito
        get group_invitation_path(group_uuid: @funghi.uuid, url_string: @invito_luigi.url_string)
        assert_response :success
        assert_difference('Invitation.count', -1) do
            assert_difference('Membership.count', 1) do
                post group_accept_invitation_path(group_uuid: @funghi.uuid, url_string: @invito_luigi.url_string)
            end
        end

        # Invia un messaggio nel nuovo gruppo con un allegato
        assert_difference('Message.count') do
            assert_difference('Attachment.count') do
              post group_messages_path(group_uuid: @funghi.uuid), params: {
                message: {
                  text: "Non vedo l'ora di cominciare!"
                },
                attachment: fixture_file_upload('files/test_image.jpg','image/jpeg')
              }
            end
        end
        @messaggio_luigi = assigns(:message)
        @allegato_luigi = assigns(:attachment)

        # Faccio log out
        get logout_path


        # Faccio log in con Mario
        log_in_as @mario

        # Accetto l'invito
        get group_invitation_path(group_uuid: @funghi.uuid, url_string: @invito_mario.url_string)
        assert_response :success
        assert_difference('Invitation.count', -1) do
            assert_difference('Membership.count', 1) do
                post group_accept_invitation_path(group_uuid: @funghi.uuid, url_string: @invito_mario.url_string)
            end
        end

        # Faccio il download dell'allegato del messaggio di Luigi
        get group_message_attachment_download_path(group_uuid: @funghi.uuid, message_id: @messaggio_luigi.id, id: @allegato_luigi.id)

        # Faccio log out
        get logout_path


        # Faccio log in con Peach
        log_in_as @peach, password: 'principessa'

        # Accedo al gruppo dei funghi
        get group_path(uuid: @funghi.uuid)

        # Ora che ci sono più utenti, setto come admin Mario
        patch group_set_admin_path(group_uuid: @funghi.uuid, user_id: @mario.id)

        # Cancello il messaggio di Luigi
        assert_difference('Message.count', -1) do
            assert_difference('Attachment.count', -1) do
                delete group_message_path(group_uuid: @funghi.uuid, id: @messaggio_luigi.id)
            end
        end

        # Cancello l'allegato del messaggio che ho inviato in precedenza
        assert_difference('Message.count', 0) do
            assert_difference('Attachment.count', -1) do
                delete group_message_attachment_path(group_uuid: @funghi.uuid, id: @messaggio_peach.id, id: @allegato_peach.id)
            end
        end

        # Modifico il corso di studio del gruppo
        get edit_group_path(uuid: @funghi.uuid)
        patch group_path(uuid: @funghi.uuid), params: {
            name: @funghi.name,
            max_members: @funghi.max_members,
            private: @funghi.private?,
            course_id: 1
        }
        @funghi.reload
        assert_equal "analisi 1", @funghi.course.name

        # Elimino Luigi dal gruppo
        assert_difference("Membership.count", -1) do
            delete group_memberships(group_uuid: @funghi.uuid, user_id: @luigi.id)
        end

        # Cerco un gruppo
        get groups_path, params: {query: cavalieri}
        @groups = assigns(:groups)
        assert_equal 1, @groups.length

        # Modifico il nome dell'utente a Principessa Peach
        get edit_user_path(@peach)
        patch user_path(@peach), params: { user: {
            name: "Principessa Peach",
            password: "principessa",
            password_confirmation: "principessa",
            email: @peach.email,
            student_attributes: {
                degree_id: 1,
                year: 1
            }
        }}

        # Faccio log out
        get logout_path

        # Provo a fare log in con Peach, ma mi sono dimenticato la password
        log_in_as @peach

        # Decido di fare reset della password
        get new_password_reset_path
        post password_resets_path, params: { password_reset:{
            email: @peach.email
        }}
        assert_equal 4, ActionMailer::Base.deliveries.size

        # Seguo tutta la procedura per il reset
        get edit_password_reset_path(@peach.password_token, email: @peach.email)
        patch password_reset_path(@peach.password_token, email: @peach.email), params: { user:{
            password: "BowserPuzza",
            password_confirmation: "BowserPuzza",
        }}

        # Entro e loggo come Peach
        assert is_logged_in?
        assert_equal User.digest("BowserPuzza"), @peach.password_digest

        # Cancello il gruppo dei funghi
        assert_difference('Group.count', -1) do
            assert_difference('Message.count', (-1) * @funghi.messages.count) do
                assert_difference('Event.count', (-1) * @funghi.events.count) do
                    assert_difference('Membership.count', (-1) * @funghi.memberships.count) do
                        assert_difference('Invitation.count', (-1) * @funghi.invitations.count) do
                            delete group_path(uuid: @funghi.uuid)
                        end
                    end
                end
            end
        end

        # Ora sono a posto, log out con Peach
        get logout_path
    end
end