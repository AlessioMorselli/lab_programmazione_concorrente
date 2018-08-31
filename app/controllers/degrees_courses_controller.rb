class DegreesCoursesController < ApplicationController
    before_action :logged_in_user
    before_action :set_degree

    # GET degrees_courses_path
    # def index
    #     # Restituisce tutti i gruppi dei corsi di studio corrispondenti al proprio corso di laurea
    #     # e al proprio anno
    #     # DOMANDA: è possibile risalire ai degrees_courses di uno user direttamente o servono più passaggi?
    #     @user_courses = current_user.degree.groups

    #     render json: @user_courses
    # end

    # GET degrees_courses_path(degree: degree.id, year: year)
    def index
        # Restituisce tutti i corsi di studio del degree e dell'anno indicati
        @courses = @degree.courses.year(params[:year])

        render json: @courses
    end

    private
    def set_degree
        @degree = Degree.find(params[:degree])
    end
end
