Feature: Admin Semester Migration functionalities
  
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
      Then I should be on Admin's user details page
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

    Scenario: See Migration Page
		Given I am on home_page
    When I click "Migrate"
    Then I should be on migrate_page
    Then I should see "Migration"
		
	Scenario: Download current semester information
    Given I am on migrate_page
    Then I should see "Migration"
    When I click "Download Current Semester Information"
    Then I should get a download with semester information named "Semester_Information-202005.csv"
    
    Scenario: Migrate to next semester
    Given I am on migrate_page
    And I enter "2021" into "sem_year"
    And I press "Migrate"
    Then I should see "Current Projects in the Database after Migration"
    And I should see "2021"
    
    
