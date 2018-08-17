require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    def setup
        @user_1 = users(:user_1)
        @user_2 = users(:user_2)

        # Prendo i gruppi di cui fanno parte...
        @groups_1 = @user_1.groups
        @groups_2 = @user_2.groups
        # ...e prendo il primo di user_1 di cui non fa parte user_2
        @group = (@groups_1 - @groups_2).first

        # Loggo come user_1 e setto i suoi cookie per l'ultimo messaggio letto
        log_in_as(@user_1)
        set_last_message_cookies(@user_1, @group, DateTime.now - 2.days)

        # Nel frattempo, creo un invito pubblico a group (mi serve poi)
        if (@invitation = Invitation.where(group_id: @group.id, user_id: nil).first).nil?
            @invitation = Invitation.new
            @invitation.group = @group
            @invitation.save!
        end
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
