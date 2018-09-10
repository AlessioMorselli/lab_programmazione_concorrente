class CoursesController < ApplicationController
    before_action :logged_in_user
    before_action :set_degree
    
    # GET degree_courses_path(degree, year: year)
    def index
        # Restituisce tutti i corsi di studio del degree e dell'anno indicati
        @courses = @degree.courses.year(params[:year])

        render json: @courses
    end

    private
    def set_degree
        begin
            @degree = Degree.find(params[:degree_id]) or not_found
        rescue ActionController::RoutingError
            render file: "#{Rails.root}/public/404", layout: false, status: :not_found
        end
    end
end
