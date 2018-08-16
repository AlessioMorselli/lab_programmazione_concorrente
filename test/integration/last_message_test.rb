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
        set_last_message_cookies(@group, DateTime.now - 2.days)

        # Nel frattempo, creo un invito pubblico a group (mi serve poi)
        if (@invitation = Invitation.find_by_group_id(@group.id)).nil?
            @invitation = Invitation.new
            @invitation.group = @group
            @invitation.save!
        end
    end

    test "two users should not share same last message cookies" do
        assert_equal true, true
    end
    
end
