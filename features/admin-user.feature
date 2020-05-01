Feature: Admin userView functionalities
  
     Background: Admin login
      Given an admin
      | Firstname         | Admin        |
      | Lastname     | Account            |
      | Email        | akapale@tamu.edu    |
      |Personal Email|admin@adminpersonal.com|
      | Password     | password            |
      | UIN          | 555555555           |

      Given a user
      | Firstname         | User1Account        |
      | Lastname     | Account1            |
      | Email        | user1@tamu.edu    |
      |Personal Email| user1@personal1.com|
      | Password     | password            |
      | UIN          | 555555551          |
      Given a user
      | Firstname         | User2Account        |
      | Lastname     | Account2            |
      | Email        | user2@tamu.edu    |
      |Personal Email| user2@personal2.com|
      | Password     | password            |
      | UIN          | 555555552           |
      
      Given a user
      | Firstname         | User3Account        |
      | Lastname     | Account3            |
      | Email        | user3@tamu.edu    |
      |Personal Email| user3@personal3.com|
      | Password     | password            |
      | UIN          | 555555553           |
      
      And I am logged in as:
      | Email        | akapale@tamu.edu    |
      | Password     | password            |
      Then I should be on 555555555's user details page
      Given there exists a project
      |Title|ProjectA|
      | Semester|Fall|
      | Year|2018|
      Given there exists a team
      |Name|Navi|
      |User_UIN|555555551|
      Given there exists a relationship
      |TeamName|Navi|
      |User_UIN|555555551|

    Scenario: All users view
    Given I am on home_page
    When I click "Users"
    And I click "All Users"
    Then I should be on users_page
    And I should see "All users"
    And I should see "User1Account Account1"
    And I should see "User2Account Account2"
    And I should see "User3Account Account3"
    # TODO check if they are sorted

    Scenario: Make/Unmake a User Admin
    Given I am on home_page
    When I click "Users"
    And I click "All Users"
    Then I should be on users_page
    When I click "User2Account Account2"
    Then I should be on 555555552's user details page
    When I click "Make Admin"
    Then I should see "User2Account is now an Administrator!"
    When I click "Remove Admin"
    Then I should see "This administrator has been removed"

    Scenario: Fail to make a user an admin if they belong to a team
    Given I am on home_page
    When I click "Users"
    And I click "All Users"
    Then I should be on users_page
    When I click "User1Account Account1"
    Then I should be on 555555551's user details page
    When I click "Make Admin"
    Then I should see "User is a member of a team and is probably a student. Cannot make them an administrator."
    
    Scenario: Prevent self-removal of admin
    Given I am on home_page
    When I click "Account"
    And I click "View Profile"
    Then I should be on 555555555's user details page
    And I should not see "Make Admin"
    And I should not see "Delete"
    
    Scenario: Delete user by admin
    Given I am on users_page
    When I click 1th "Delete"
    Then I should see "This user is a team leader! You need to delete their team first"
    When I click 2th "Delete"
    Then I should see "User Deleted Permanently!"
    
    Scenario: Edit user by admin
    Given I am on users_page
    When I click 1th "Edit"
    Then I should be on 555555551's user edit page
    When I press "Save Changes"
    Then I should see "Profile updated"
    And I should be on 555555551's user details page
    
    Scenario: Download all users
    Given I am on home_page
    When I click "All Users"
    Then I should be on users_page
    When I click "Download data as Excel"
    Then I should get a download with the filename "Users_Data.xlsx"
