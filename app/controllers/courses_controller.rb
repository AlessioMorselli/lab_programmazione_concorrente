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
        @degree = Degree.find(params[:degree_id])
    end
end
