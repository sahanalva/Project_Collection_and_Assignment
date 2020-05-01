class UsersController < ApplicationController
    before_action :logged_in_user, only:
        %i[index show edit update upload destroy
   iteration0 iteration1 iteration2 iteration3 iteration4 poster first_video final_video
   final_report project filename]
    before_action :correct_user, only: %i[show edit update]
    before_action :admin_user, only: %i[index destroy]

    def index
        if params[:search_by].nil? and params[:sort_by].nil?
            session[:search_by] = nil
            session[:search_by] = nil
            session[:search] = nil
        end 

        session[:search_by] = nil unless session.key?(:search_by)
        session[:search] = nil unless session.key?(:search)

        @sorting = params[:sort_by] 

        @search = params[:search] || session[:search]
        @search_by = params[:search_by] || session[:search_by]  # If 1st expression is not nil/true, return it. If the 1st expression is nil/false, return the 2nd expression
        
        session[:search_by] = @search_by 
        session[:search] = @search

        if session[:search_by] == '1' # Search using UIN
            @users = User.search_by_uin(session[:search])
        elsif session[:search_by] == '2' # Search using Name
            @users = User.search_by_name(session[:search])
        elsif session[:search_by] == '3' #Search using Team Name
            @users = User.search_by_currteam(session[:search])
        else
            @users = User.all
        end 

        if !@users.nil?
            @teams = {}

            @users.each do |user|
                res = Relationship.find_by_user_id(user.id)
                @teams[user.id] = (Team.find_by_id(res.team_id) unless res.nil?)
            end

            session[:teamorder] = nil unless session.key?(:teamorder)

            if @sorting == 'currteam'
                nil_team_users = @users.select {|x| @teams[x.id].nil?}
                other_team_users = @users.reject {|x| @teams[x.id].nil?}

                if session[:teamorder] == false
                    @users = (other_team_users + nil_team_users)
                    session[:teamorder] = true

                else
                    @users = (nil_team_users + other_team_users)
                    session[:teamorder] = false

                end
            else
                @users = @users.order(@sorting)
            end
        end 

        respond_to do |format|
            format.xlsx do
                response.headers[
                    'Content-Disposition'
                ] = "attachment; filename=Users_Data.xlsx"
            end
            format.html do
                @users = @users.paginate(page: params[:page])
                render :index
            end
        end
    end

    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            log_in @user
            flash[:success] = 'Welcome to the ProjectApp'
            redirect_to @user
        else
            render 'new'
        end
    end

    def edit
        @user = User.find(params[:id])
    end

    def project
        @user = User.find(params[:user_id])

        return unless have_permission?

        @relationship = Relationship.find_by_user_id(params[:user_id])

        return unless have_team?

        @team = Team.find(@relationship.team_id)
        @assignment = Assignment.find_by_team_id(@team.id)

        return unless have_project?

        @project = Project.find(@assignment.project_id)
        redirect_to project_path(@project)
    end

    def update
        @user = User.find(params[:id])
        if @user.update_attributes(user_params)
            flash[:success] = 'Profile updated'
            redirect_to @user
        else
            render 'edit'
        end
    end

    def make_admin
        @user = User.find(params[:user_id])
        if current_user?(@user)
            flash[:danger] = 'To prevent accidental lockout, you cannot alter user role for yourself. Contact a different administrator.'
        elsif @user.is_member_of.present?
            flash[:danger] = 'User is a member of a team and is probably a student. Cannot make them an administrator.'
        elsif !@user.admin
            @user.update_attribute(:admin, true)
            flash[:success] = @user.firstname + ' is now an Administrator!'
        else
            @user.update_attribute(:admin, false)
            flash[:success] = 'This administrator has been removed'
        end
        redirect_to @user
    end

    def no_team
        @users = []
        @teams = {}

        User.all.each do |user|
            res = Relationship.find_by_user_id(user.id)
            @users.push(user) if res.nil?
        end

        @users_all = @users
        @users = @users.paginate(page: params[:page])

        respond_to do |format|
            format.xlsx do
                response.headers[
                    'Content-Disposition'
                ] = "attachment; filename=Users_NoTeam_Data.xlsx"
            end
            format.html {render :no_team}
        end
    end

    def admin_download
        admin_user

        @user = User.find(params[:user_id])
        @relationship = Relationship.find_by_user_id(params[:user_id])
        team_id = @relationship.team_id
        cmd = 'tar czf ./public/uploads/' + team_id.to_s + '.tar.gz' + ' ./public/uploads/' + team_id.to_s
        system(cmd)
        send_file('./public/uploads/' + team_id.to_s + '.tar.gz', filename: team_id.to_s + '.tar.gz', type: 'application/x-tar')
    end

    def destroy
        team = Team.find_by_user_id(params[:id])

        if team.nil?
            User.find(params[:id]).destroy
            flash[:success] = 'User Deleted Permanently!'

        else
            flash[:warning] = 'This user is a team leader! You need to delete their team first'
        end
        # redirect_to users_url
        redirect_back fallback_location: users_url
    end

    private

    def user_params
        params.require(:user).permit(:firstname, :lastname, :uin, :email, :personal_email, :password,
                                     :password_confirmation, :semester, :year, :course)
    end

    def search_params
        params.require(:user).permit(:firstname, :search)
    end
end
