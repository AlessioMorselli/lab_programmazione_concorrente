class MembershipsController < ApplicationController
    # GET group_memberships(group)
    def index
        # Recupera tutti i membri di un gruppo, in modo da poter visualizzare chi fa parte di un gruppo
        # e chi è online in quel momento
    end

    private
    def set_memberships
      @group = Member.find(params[:id])
    end

    def membership_params
      params.require(:member).permit(:group_id, :user_id, :admin)
    end
end
