class ResetController < ApplicationController
    before_action :logged_in_user
    before_action :admin_user

    def downloadAndReset
        # Download Projects
        projects = Project.all
        i = 1
        data = "SNo, Project Title, Organization, Contact, Description, On Campus, Legacy SW, Approved\n"
        projects.each do |p|
            legacy = if p.islegacy.to_s == 'true'
                         'Yes'
                     else
                         'No'
                     end
            oncampus = if p.oncampus.to_s == 'true'
                           'Yes'
                       else
                           'No'
                       end
            approved = if p.approved.to_s == 'true'
                           'Yes'
                       else
                           'No'
                       end
            data << i.to_s << ',' << p.title << ',' << p.organization.to_s.inspect << ',' << p.contact.to_s.inspect << ',' << p.description.to_s.inspect << ',' << oncampus.to_s << ',' << legacy.to_s << ',' << approved.to_s << "\n"
            i += 1
        end
        date = Time.now.strftime('%Y%m')
        send_data data, filename: "projects-#{date}.csv"

        # reset the DBs
        Assignment.delete_all
        User.where(admin: false).delete_all
        Preassignment.delete_all
        Preference.delete_all
        Project.delete_all
        Relationship.delete_all
        Team.delete_all
    end

    def migrate
        puts "Migration in progress"
        all_projects = Project.all
        clones = []
        all_projects.each do |project|
            clone_project = project.dup
            clone_project.islegacy = true
            clone_project.legacy_id = project.id

            # Handle migration of semester to the next.
            # TODO: User should choose the next semester.
            # TODO: This currently clones all older projects as well, creating 2^number_of_migrate clones.
            if project.semester == "Winter"
                clone_project.semester = 'Spring'
                clone_project.year = project.year.to_i + 1
            elsif project.semester == "Spring"
                clone_project.semester = "Summer"
            elsif project.semester == "Summer"
                clone_project.semester = "Fall"
            elsif project.semester == "Fall"
                clone_project.semester = 'Spring'
                clone_project.year = project.year.to_i + 1
            end
            clones << clone_project
        end

        puts "Length of projects before clone = "
        puts Project.all.length
        Project.import clones

        puts "Length of projects after clone = "
        puts Project.all.length

        # reset the DBs
        Assignment.delete_all
        User.where(admin: false).delete_all
        Preassignment.delete_all
        Preference.delete_all
        Project.where(islegacy: false).delete_all
        Relationship.delete_all
        Team.delete_all

        puts "Length of projects after deleting non-legacy = "
        puts Project.all.length
    end
end
