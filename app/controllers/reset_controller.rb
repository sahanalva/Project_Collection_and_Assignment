class ResetController < ApplicationController
    before_action :logged_in_user
    before_action :admin_user

    def index
        @projects = Project.order('year DESC,semester DESC').all.paginate(page: params[:page])
    end

    def downloadAndReset
        # Download Projects
        projects = Project.all
        i = 1
        data = "SNo, Project Title, Semester, Organization, Contact, Description, Students who worked on the Project, Github Link, Heroku Link, Pivotal Tracker\n"
        projects.each do |p|
            student_data = ""
            team_info = Assignment.find_by_project_id(p.id)
            team_number = team_info.team_id unless team_info.nil? 
            @student_info = Relationship.where(team_id: team_number)
            if !@student_info.nil?
                @student_info.each do |student|
                    firstname = User.find_by_id(student.user_id).firstname
                    lastname = User.find_by_id(student.user_id).lastname
                    email = User.find_by_id(student.user_id).personal_email
                    student_data << firstname.to_s << ' ' << lastname.to_s << ' <' << email.to_s << '> '
                end 
            end

            data << i.to_s << ',' << p.title << ',' << p.semester.to_s << ' ' << p.year.to_s << ',' << p.organization.to_s.inspect << ',' << p.contact.to_s.inspect << ',' << p.description.to_s.inspect << ',' << student_data << ',' << p.github_link.to_s << ',' << p.heroku_link.to_s << ',' << p.pivotal_link.to_s << "\n"
            i += 1
        end
        # date = Time.now.strftime('%Y%m')
        send_data data, filename: "Semester_Information.csv"

    end

    def migrate

        @year = params[:year] 
        @semester = params[:semester]

        puts "Migration in progress"
        active_projects = Project.where(isactive: true)
        active_projects.each do |project|
            project.islegacy = true
            # Handle migration of semester to the next.
            # TODO: First update the semester/year as part of migration UI.
            project.semester = @semester
            project.year = @year
            project.save
        end

        # reset the DBs
        Assignment.delete_all
        User.where(admin: false).delete_all
        Preassignment.delete_all
        Preference.delete_all
        Relationship.delete_all
        Team.delete_all

        @projects = Project.order('year DESC,semester DESC').all.paginate(page: params[:page])
    end
end
