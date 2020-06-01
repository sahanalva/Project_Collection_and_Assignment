# module NavigationHelpers
#  def path_to(page_name)
#    case page_name

#   when /^User_Details$/ then '/users/1'
#    when /the home\s?page/
#      '/users/1'
#    when /login_page/
#      '/login'
#    when /Users/
#      '/users'
#    else
# begin
#  page_name =~ /the (.*) page/
#  path_components = $1.split(/\s+/)
#  self.send(path_components.push('path').join('_').to_sym)
# rescue Object => e
#  raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
#    "Now, go and add a mapping in #{__FILE__}"
#     #end
#    end
#  end
# end

# World(NavigationHelpers)

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /home_page/
      '/'
    # when /^home\s?page/
    #   '/'
    when /login_page/
      '/login'

    when /login_netid_page/
      '/login_netid'
    when /login_page/
      '/login'
    when /^forgot_password_page/
      '/password_resets/new'
    when /^password_reset_page/
      '/password_resets/new'
    when /^projects/ then '/projects'

    when /signup_page/ then '/signup'

    #    when /user_details/ then '/users/1'

    when /^(.*)'s user details page$/i
      user_path(User.find_by(Firstname: Regexp.last_match(1)))

    when /^(.*)'s user edit page$/i
      edit_user_path(User.find_by(Firstname: Regexp.last_match(1)))

    when /^(.*)'s project details page$/i
      project_path(Project.find_by(title: Regexp.last_match(1)))

    when /^(.*)'s project edit page$/i
      edit_project_path(Project.find_by(title: Regexp.last_match(1)))

    when /wrong_user_details/ then '/users/383728'

    when /jointeam_page/ then '/jointeam'

    when /createteam_page/ then '/teams/new'

    when /approved_projects/ then '/approved_projects'

    when /addproposal/ then '/add_project'

    when /myproposal/ then '/myproposals_projects'

    when /assignedpro/ then '/projects/'

    when /assign_projects_path/ then '/viewassign'

    when /pest/ then '/peer_evaluation'
    when /reset_database_page/ then '/resetDB'
    when /download/ then '/download'

    #    when /update_details/ then '/users/1/edit'

    when /^(.*)'s update details page/i
      edit_user_path(User.find_by(Firstname: Regexp.last_match(1)))

    when /^(.*)'s update team page/i
      edit_team_path(Team.find_by(name: Regexp.last_match(1)))

    when /^(.*)'s team details page/i
      team_path(Team.find_by(name: Regexp.last_match(1)))

    when /wrong_update_details/ then '/users/383728/edit'

    when /myteam/ then '/teams'
    when /teams/ then '/teams'
    when /users_page/ then '/users'

    when /about_page/ then '/about'

    when /contact_page/ then '/contact'

    when /help_page/ then '/help'
    
    when /migrate_page/ then '/migrate'

    when /unapproved_projects_page/ then '/unapproved_projects'
    when /add_projects_page/ then '/add_project'
    when /myproposals_projects_page/ then '/myproposals_projects'
    when /peer_evaluation_page/ then '/peer_evaluation'
      
    when /preferences_page/ then '/teams/1/preference'

    #    when /^the edit page for "(.*)"$/
    #  edit_movie_path Movie.find_by_title($1)

    #    when /^the details page for "(.*)"$/
    # movie_path Movie.find_by_title($1)

    #    when /^the Similar Movies page for "(.*)"$/
    #  same_director_path Movie.find_by_title($1)

    #    when /^the RottenPotatoes home page$/ then '/movies'

    #    when /^the (RottenPotatoes)?home\s?page$/ then '/movies'

    #    when /^the movies page$/ then '/movies'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = Regexp.last_match(1).split(/\s+/)
        send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
