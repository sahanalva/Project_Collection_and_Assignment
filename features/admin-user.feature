Feature: Admin userView functionalities
  
     Background: Admin login
      Given an admin
      | Firstname         | Admin        |
      | Lastname     | Account            |
      | Email        | akapale@tamu.edu    |
      | Password     | password            |
      | UIN          | 555555555           |

      Given a user
      | Name         | User1Account        |
      | Email        | ak1@tamu.edu    |
      | Password     | password            |
      | UIN          | 111111111|
      Given a user
      | Name         | User2Account        |
      | Email        | ak2@tamu.edu    |
      | Password     | password            |
      | UIN          | 111111112|
      
      Given a user
      | Name         | User3Account        |
      | Email        | ak3@tamu.edu    |
      | Password     | password            |
      | UIN          | 111111113|
      
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
      |User_UIN|555555555|

    Scenario: All users view
    Given I am on home_page
    When I click "Users"
    Then I should be on users_page
    And I should see "All users"
    And I should see "User1Account"
    And I should see "User2Account"
    When I click "UIN"
    Then I should see "111111111"
    And I click "Name"
    Then I should see "User1Account"
    And I click "Current Team"
    Then I should see "Unassigned"
    # TODO check if they are sorted

    Scenario: Make/Unmake a User Admin
    Given I am on home_page
    When I click "Users"
    Then I should be on users_page
    When I click "User1Account"
    Then I should be on User1Account's user details page
    When I click "Make Admin"
    Then I should see "User1Account is now an Administrator!"
    When I click "Remove Admin"
    Then I should see "This administrator has been removed"
    
    
    Scenario: Delete user by admin
    Given I am on users_page
    When I click 1th "Delete"
    Then I should see "This user is a team leader! You need to delete his team first"
    When I click 2th "Delete"
    Then I should see "User Deleted Permanently!"
    
    Scenario: Edit user by admin
    Given I am on users_page
    When I click 1th "Edit"
    Then I should be on User1Account's user edit page
    When I press "Save Changes"
    Then I should see "Profile updated"
    And I should be on User1Account's user details page
    
    Scenario: Download all users
    Given I am on home_page
    When I click "All Users"
    Then I should be on users_page
    When I click "Download data as Excel"
    Then I should get a download with the filename "Users_Data.xlsx"
