require 'test_helper'

class FrienlyForwardingTest < ActionDispatch::IntegrationTest
    def setup
        @user = users(:giorgio)
        @group = groups(:samurai)
    end

    test "should use friendly forwarding with get request" do
        # Cerco di accedere alla pagina di @group
        get group_path(uuid: @group.uuid)

        # Verifico di essere stato reindirizzato alla pagina di login
        assert_redirected_to login_path

        # Loggo come @user
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciaone" } }

        # Verifico di essere loggato correttamente
        assert is_logged_in?

        # Verifico di essere stato reindirizzato alla pagina di @group
        assert_redirected_to group_path(uuid: @group.uuid)
    end
    
    test "should not use friendly forwarding with not-get request" do
        events_number = @group.events.count

        # Cerco di creare un evento in @group
        post group_events_path(group_uuid: @group.uuid), params: { event: {
            start_time: DateTime.now + 1.hours,
            end_time: DateTime.now + 3.hours,
            place: "Aula studio - Secondo piano",
            description: "2 ore di studio di programmazione concorrente",
            group_id: @group.id
            }
        }

        # Verifico di essere reindirizzato alla pagina di login
        assert_redirected_to login_path

        # Loggo come @user
        post login_path, params: { session: { email:    @user.email,
                                              password: "ciaone" } }

        # Verifico di essere loggato correttamente
        assert is_logged_in?

        # Verifico di essere stato reindirizzato alla lista dei gruppi e
        # che nessun evento sia stato creato in @group
        assert_equal events_number, @group.events.count
        assert_redirected_to groups_path
    end
end