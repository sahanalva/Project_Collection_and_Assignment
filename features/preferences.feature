Feature: Preferences related features
  
  	  Background: User is logged_in and has created a team
  	  Given an admin
      | Firstname         | AdminAccount        |
      | Email        | akapale@tamu.edu    |
      Given a user
      | Firstname         | UserAccount        |
      | Email        | ak@tamu.edu    |
      | UIN | 111111111 |
      Given a user
      | Firstname         | User2Account        |
      | Email        | ak2@tamu.edu    |
      | UIN          | 111111112|
      And I am logged in as:
      | Email        | ak@tamu.edu    |
      Given there exists a project
      |Title|ProjectA|
      When I click "Team"
      And I click "Create Team"
      And I fill the team name:
      |Name|Navi|
      And I press "Create Team"
      Then I should see "Team created successfully"
        
   
     Scenario: Fill Project Preferences
  	  Given I am on home_page
  	  When I click "Projects"
      When I click "Project Preference"
      Then I press "Submit Final Preferences"
      Then I should see "Preferences Saved"
      Then I should be on 111111111's user details page
     
  	  Scenario: View Project Preferences (second time)
  	  Given I am on home_page
  	  When I click "Projects"
      When I click "Project Preference"
      Then I press "Submit Final Preferences"
      Then I should see "Preferences Saved"
      Then I should be on 111111111's user details page
  	  When I click "Projects"
      When I click "Project Preference"
      Then I should see "Preferences have already been submitted"
      Then I should be on preferences_page
     
     Scenario: View Project Preferences (team member)
      Given I am on home_page
  	  When I click "Projects"
      When I click "Project Preference"
      Then I press "Submit Final Preferences"
      Then I should see "Preferences Saved"
      Then I should be on 111111111's user details page
      Given I am on home_page
      And I click "Log Out"
      Then I am logged in as:
      |Email|akapale@tamu.edu|
      Then I visit teams_page
      Then I should see "Navi"
      And I click "Navi"
      And I select "User2Account"
      And I press "Add user"
      Given I am on home_page
  	  And I click "Log Out"
  	  Given I am logged in as:
      | Email        | ak2@tamu.edu    |
  	  When I click "Projects"
      When I click "Project Preference"
      Then I should be on preferences_page
     
     Scenario: Submit Team Peer Evaluation (Happy)
      Given I am on home_page
      When I click "Project"
      And I click "Peer Evaluation"
      And I fill the peer evaluation:
      |Score |10|
      | Comments|'He is Awesome'|
      And I press "Submit"
      Then I should see "Peer evaluation results have been saved"
     
     Scenario: Submit Team Peer Evaluation (Sad1)
      Given I am on home_page
      When I click "Project"
      And I click "Peer Evaluation"
      And I press "Submit"
      Then I should see "The scores should sum to"