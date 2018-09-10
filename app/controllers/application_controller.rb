class ApplicationController < ActionController::Base
    # layout false
    include SessionHelper

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end
end
