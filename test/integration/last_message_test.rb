require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    def setup
        @user_1 = users(:giorgio)
        @user_2 = users(:giovanni)
        @group = groups(:pirati)

        # Loggo come user_1 e setto i suoi cookie per l'ultimo messaggio letto
        log_in_as(@user_1)
        set_last_message_cookies(@user_1, @group, DateTime.now - 2.days)

        @invitation = invitations(:invito_pirati)
    end

    test "two users should not share same last message cookies" do
        # Accedo al gruppo con user_1
        get group_path(uuid: @group.uuid)

        # Verifico che i cookie siano impostati su DateTime.now (salvato su variabile)
        now = DateTime.now
        assert_equal now.to_s, cookies[@user_1.id.to_s + @group.uuid]
    
        # Faccio log out
        delete logout_path

        # Faccio log in con user_2
        log_in_as(@user_2)

        # Verifico che i cookie per il gruppo non esistano
        assert_nil cookies[@user_2.id.to_s + @group.uuid]

        # Accetto l'invito al gruppo
        get group_accept_invitation_path(group_uuid: @group.uuid, url_string: @invitation.url_string)

        # Verifico che i cookie siano impostati a default
        assert_equal (DateTime.now - 1.days).to_s, cookies[@user_2.id.to_s + @group.uuid]

        # Accedo al gruppo
        get group_path(uuid: @group.uuid)

        # Verifico che i cookie siano impostati su DateTime.now
        assert_equal DateTime.now.to_s, cookies[@user_2.id.to_s + @group.uuid]

        # Faccio log out
        delete logout_path

        # Faccio log in con user_1
        log_in_as(@user_1)

        # Verifico che i cookie siano impostati come prima
        assert_equal now.to_s, cookies[@user_1.id.to_s + @group.uuid]
    end
    
end
