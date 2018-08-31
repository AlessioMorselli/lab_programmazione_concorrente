class DegreesCoursesController < ApplicationController
    before_action :logged_in_user

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
        @courses = DegreeCourse.metodo_fasullo(params[:degree], params[:year])

        render json: @courses
    end
end
