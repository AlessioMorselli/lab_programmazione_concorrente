class DegreeCoursesController < ApplicationController
    before_action :set_degree_course, only: [:show]

    # GET degree_courses_path
    def index
        # Restituisce tutti i gruppi dei corsi di studio corrispondenti al proprio corso di laurea
        # e al proprio anno
    end

    # GET degree_course_path(degree_course)
    def show
        # Visualizza la chat del gruppo del corrispondente corso di studio
    end

    private
    def set_degree_course
      @course = DegreeCourse.find(params[:id])
    end

    def group_params
      params.require(:degree_course).permit(:year, :course_id, :degree_id, :group_id)
    end
end
