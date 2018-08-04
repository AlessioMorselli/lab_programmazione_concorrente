class MembersController < ApplicationController
    # GET group_members(group)
    def index
        # Recupera tutti i membri di un gruppo, in modo da poter visualizzare chi fa parte di un gruppo
        # e chi è online in quel momento
    end

    private
    def set_member
      @group = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:group_id, :user_id)
    end
end
