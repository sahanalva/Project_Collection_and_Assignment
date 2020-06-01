class ProjectsController < ApplicationController
    before_action :logged_in_user, only: %i[index show edit update destroy approve unapprove approved unapproved toggle]
    before_action :admin_user, only: %i[index edit update destroy approve unapprove unapproved toggle]
    skip_before_action :admin_user, only: %i[destroy edit update]

    def index
        @title = 'all_projects'
        @sorting = params[:sort]
        @path = 'projects_path'
        if @sorting == 'year'
            @projects = Project.order('year DESC,semester DESC').all.paginate(page: params[:page])
        else
            @projects = Project.order(@sorting).all.paginate(page: params[:page])
        end
    end

    def approved
        @title = 'approved_projects'
        @path = 'approved_projects_path'
        @sorting = params[:sort]
        if @sorting == 'year'
            @projects = Project.order('year DESC,semester DESC').where('approved = ?', true).where('isactive = ?', true).paginate(page: params[:page])
        else
            @projects = Project.order(@sorting).where('approved = ?', true).where('isactive = ?', true).paginate(page: params[:page])
        end
        render 'index'
    end

    def unapproved
        @title = 'unapproved_projects'
        @path = 'unapproved_projects_path'
        @sorting = params[:sort]
        if @sorting == 'year'
            @projects = Project.order('year DESC,semester DESC').where('approved = ?', false).where('isactive = ?', true).paginate(page: params[:page])
        else
            @projects = Project.order(@sorting).where('approved = ?', false).where('isactive = ?', true).paginate(page: params[:page])
        end
        render 'index'
    end

    def myproposals
        @title = 'My Proposals'

        owned_projects = Own.where(user_id: current_user)
        unapproved_projects = Project.where('approved = ?', false)

        @projects = {}
        @projects['Approved'] = []
        @projects['Unapproved'] = []

        owned_projects.each do |owned_proj|
            # if(!Project.exists?(:id => owned_proj.project_id))
            #       next
            # end

            p = Project.find(owned_proj.project_id)

            if p.approved?
                @projects['Approved'] << p
            else
                @projects['Unapproved'] << p
            end
        end
    end

    def list_all_users_peer_evaluation
        @all_pe = []
        all_users = User.all
        all_users.each do |user|
            next if user.admin?

            user_pe = []
            user_pe << user.firstname + ' ' + user.lastname

            # get team name
            team = user.is_member_of
            if team.nil?
                user_pe << ''
                user_pe << ''
                user_pe << ''
                user_pe << user.id
                user_pe << -1
            else
                user_pe << team.name

                score = 0
                comment = []
                members = team.members
                members.each do |member|
                    member_record = User.find_by(id: member.id)
                    pe = member_record.peer_evaluation
                    next unless !pe.nil? && !pe.empty? && pe.key?(user.id.to_s)

                    if pe[user.id.to_s].key?('score')
                        score += pe[user.id.to_s]['score'].to_i
                    end
                    if pe[user.id.to_s].key?('comment')
                        comment << pe[user.id.to_s]['comment']
                    end
                end

                # comment_str = ""
                # comment.each_with_index do |c, i|
                #         comment_str += "<pre>" + c + "</pre>"
                #         if i < comment.size - 1
                #                 comment_str += " <br\> "
                #         end
                # end

                user_pe << score
                user_pe << comment

                user_pe << user.id
                user_pe << team.id
                user_pe << team.members.size

            end

            @all_pe << user_pe
        end

        p '###########'
        p @all_pe

        render 'all_users_peer_evaluation'
    end

    def list_team_peer_evaluation
        @team = Team.find_by(id: params['check_team_peer_evaluation'].to_i)
        if @team.nil?
            flash.now[:danger] = "Can't find the team"
            redirect_to :back
            return
        end

        @all_pe = []
        all_users = @team.members
        all_users.each do |user|
            next if user.admin?

            user_pe = []
            user_pe << user.firstname + ' ' + user.lastname

            all_users.each do |member|
                member_record = User.find_by(id: member.id)
                pe = member_record.peer_evaluation
                user_pe << if !pe.nil? && !pe.empty? && pe.key?(user.id.to_s)
                               if pe[user.id.to_s].key?('score')
                                   pe[user.id.to_s]['score'].to_i
                               else
                                   ''
                               end
                           else
                               ''
                           end
            end

            all_users.each do |member|
                member_record = User.find_by(id: member.id)
                pe = member_record.peer_evaluation
                user_pe << if !pe.nil? && !pe.empty? && pe.key?(user.id.to_s)
                               if pe[user.id.to_s].key?('comment')
                                   pe[user.id.to_s]['comment']
                               else
                                   ''
                               end
                           else
                               ''
                           end
            end

            @all_pe << user_pe
        end

        p '###########'
        p @all_pe

        render 'team_peer_evaluation'
    end

    def do_peer_evaluation
        if current_user.admin? && params.key?('check_team_peer_evaluation')
            list_team_peer_evaluation
            return
        end

        if !current_user.admin? || (current_user.admin? && params.key?('check_one_user_peer_evaluation'))
            the_user_id = -1
            if current_user.admin? && params.key?('check_one_user_peer_evaluation')
                the_user_id = params['check_one_user_peer_evaluation'].to_i
            else
                the_user_id = current_user.id
            end

            @current_pe = {}
            if @last_pe_submission.nil? || @last_pe_submission.empty?
                p 'hahaha', the_user_id
                user = User.find_by(id: the_user_id)
                @current_pe = user.peer_evaluation
            else
                @current_pe = @last_pe_submission
            end

            p '*******************************'
            p @current_pe

            @current_pe_valid = !@current_pe.nil? && !@current_pe.empty? ? true : false

            # @title = "Unapproved Projects"
            the_user = User.find_by(id: the_user_id)
            p the_user
            p '*******************************'
            @team = the_user.is_member_of
            p @team
            if @team.nil?
                flash[:danger] = 'Failed to retrieve the peer evaluation form because the team is missing.'
                @title = 'Approved Projects'
                @projects = Project.where('approved = ?', true).where('isactive = ?', true).paginate(page: params[:page])
                redirect_back fallback_location: root_path # Refactored for Rails 5
                return
            end
            @members = @team.members
            render 'peer_evaluation'
            return
        end

        list_all_users_peer_evaluation
    end

    def submit_peer_evaluation
        unless params.key?(:peer_evaluation)
            flash.now[:danger] = 'The content of peer evaluation is missing.'
            do_peer_evaluation
            return
        end

        result = {}

        params[:peer_evaluation].each do |key, value|
            key_list = key.split('.')
            if !result.key?(key_list[0])
                result[key_list[0]] = {key_list[1] => value}
            else
                result[key_list[0]] = {} if result[key_list[0]].empty?
                result[key_list[0]][key_list[1]] = value
            end
        end

        @last_pe_submission = result

        score_sum = 0
        result.each do |_key, value|
            score_sum += value['score'].to_i if value.key?('score')
        end

        if score_sum != result.size * 10
            flash.now[:danger] = 'The scores should sum to ' + (result.size * 10).to_s + '.'

            do_peer_evaluation
            return
        end

        user = User.find_by(id: current_user.id)
        user.peer_evaluation = result
        user.save!

        flash.now[:success] = 'Peer evaluation results have been saved.'
        do_peer_evaluation
    end

    def show
        @project = Project.find(params[:id])
        @assignment = Assignment.find_by_project_id(@project.id)
        @members = []
        @team = nil

        @owned = Own.find_by_project_id(params[:id])
        @owner = User.find_by_id(@owned.user_id) unless @owned.nil?
        @created_user = true if current_user.id == @owner.id unless @owned.nil?

        unless @assignment.nil?

            @team = Team.find(@assignment.team_id)

            @member_ids = Relationship.where(team_id: @team.id).all
            @member_ids.each do |member| # TO aggregate the members of each team. But isn't an array clumsy?
                tmp = User.find(member.user_id.to_i)
                @members << tmp.firstname.to_s

                next if @team.nil?

                @assigned_user = true if current_user.is_member?(@team)
            end
        end

        @legacy_project = Project.find_by_id(@project.legacy_id)

        # if !current_user.admin?  && (!@project.approved? || (@owned!=nil && @owned.user_id != current_user.id))
        unless logged_in?
            flash[:danger] = 'You do not have priviledge to view this project'
            redirect_to approved_projects_url
        end
    end

    def new
        @project = Project.new
        @opt = Project.all.order('title').where('isactive = ?', true)
        @options = @opt.collect {|p| [p.title, p.id]}

        @semester = current_user.admin? ? nil : current_user.semester
        @year = current_user.admin? ? nil : current_user.year
    end

    def create
        @project = Project.new(project_params)

        if @project.save
            current_user.owns.create(project_id: @project.id)
            flash[:success] = 'Project Added for Approval'

            if current_user.admin?
                redirect_to unapproved_projects_url

            else
                redirect_to myproposals_projects_url

            end
        else
            # render 'new'
            flash[:danger] = 'ERROR: Missing required parameters'
            redirect_to add_project_path
        end
    end

    def edit
        @project = Project.find(params[:id])

        @opt = Project.all.order('title').where('isactive = ?', true)
        @options = @opt.collect {|p| [p.title, p.id]}

        owned = Own.find_by_project_id(params[:id])
        @readonly_flag = true
        @readonly_flag = false if current_user.admin?
        @readonly_flag = false if !owned.nil? && current_user.id == owned.user_id

        if @readonly_flag
            redirect_to(@project)
        end
        @semester = current_user.admin? ? nil : current_user.semester
        @year = current_user.admin? ? nil : current_user.year
    end

    def update
        @project = Project.find(params[:id])

        if @project.update_attributes!(project_params) # last minute change to allow git and pt saves
            flash[:success] = 'Project details updated'
            redirect_to @project
        else
            render 'edit'
        end
    end

    def destroy
        Project.find(params[:id]).destroy

        x = Own.find_by_project_id(params[:id])
        x.destroy unless x.nil?

        assigned = Assignment.find_by_project_id(params[:id])
        assigned.destroy unless assigned.nil? # Delete this project's assignment if any

        flash[:success] = 'Project deleted'

        if current_user.admin?
            redirect_to projects_url

        else
            redirect_to myproposals_projects_url(current_user)
        end
    end

    def documentation
        @project = Project.find(params[:project_id])
        @documents = Document.where(project_id: params[:project_id])

        @users = []
        @documents.each do |x|
            @documents.inspect

            auser = User.find_by_id(x.author)

            if auser.nil? # For some reason this user has been deleted
                @users << [nil, 'Deleted User'] # Inform front end that this user no longer exists
            else
                @users << [auser.id, auser.firstname]
            end
        end

        active_assignment = Assignment.find_by_project_id(@project.id)

        team = active_assignment.nil? ? nil : Team.find(active_assignment.team_id)

        team_id = team.nil? ? nil : team.id

        @member_ids = Relationship.where(team_id: team_id, user_id: current_user).all

        # If current user is a member of this team
        @auth = @member_ids.empty? ? false : true
    end

    # Commenting as this code is not in use currently
    #         def approve
    #                 project = Project.find_by(id: params[:id])
    #                 if project
    #                         if project.approved?
    #                                 flash[:info] = "Project already approved"
    #                                 redirect_to projects_url
    #                         else
    #                                 project.approved = true
    #                                 project.save
    #                                 flash[:success] = "Project approved successfully"
    #                                 redirect_to projects_url
    #                         end
    #                 else
    #                         flash[:danger] = "Project does not exist"
    #                         redirect_to root_url
    #                 end
    #         end
    #
    #         def unapprove
    #                 project = Project.find_by(id: params[:id])
    #                 if project
    #                         if !project.approved?
    #                                 flash[:info] = "Project already unapproved"
    #                                 redirect_to projects_url
    #                         else
    #                                 project.approved = false
    #                                 project.save
    #                                 flash[:success] = "Project unapproved successfully"
    #                                 redirect_to projects_url
    #                         end
    #                 else
    #                         flash[:danger] = "Project does not exist"
    #                         redirect_to root_url
    #                 end
    #         end

    def toggle
        @project = Project.find(params[:id])
        @project.toggle(:approved)
        @project.save
        respond_to do |format|
            format.html {redirect_to projects_url}
            format.js
        end
    end

    def toggle_active
        @project = Project.find(params[:id])
        @project.toggle(:isactive)
        @project.save
        respond_to do |format|
            format.html {redirect_to projects_url}
            format.js
        end
    end

    private

    def project_params
        if current_user && current_user.admin?
            params.require(:project).permit(:title, :organization, :contact, :description, :oncampus, :islegacy, :approved, :semester, :year, :legacy_id, :github_link, :heroku_link, :pivotal_link, :isactive)
        else
            params.require(:project).permit(:title, :organization, :contact, :description, :oncampus, :islegacy, :semester, :year, :legacy_id, :github_link, :heroku_link, :pivotal_link)
        end
    end

end
