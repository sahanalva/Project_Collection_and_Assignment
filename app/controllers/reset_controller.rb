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
        active_projects = Project.where(isactive: true)
        active_projects.each do |project|
            project.islegacy = true
            # Handle migration of semester to the next.
            # TODO: First update the semester/year as part of migration UI.
            project.semester = Setting.semester
            project.year = Setting.year
            project.save
        end

        # reset the DBs
        Assignment.delete_all
        User.where(admin: false).delete_all
        Preassignment.delete_all
        Preference.delete_all
        Relationship.delete_all
        Team.delete_all
    end
end
