class DegreesCoursesController < ApplicationController
    # before_action :set_degrees_course, only: [:show, :edit, :update, :destroy]

    # GET degrees_courses_path
    def index
        # Restituisce tutti i gruppi dei corsi di studio corrispondenti al proprio corso di laurea
        # e al proprio anno
        # DOMANDA: è possibile risalire ai degrees_courses di uno user direttamente o servono più passaggi?
        user_courses = current_user.degrees_courses
        @user_courses_groups = []

        user_courses.each do |course|
            @user_courses_groups.push(course.group)
        end
    end

    # private
    # def set_degrees_course

    #     @degrees_course = DegreesCourse.find(params[:id])
    # end

    # def group_params
    #     params.require(:degrees_course).permit(:year, :course_id, :degree_id, :group_id)
    # end
end
