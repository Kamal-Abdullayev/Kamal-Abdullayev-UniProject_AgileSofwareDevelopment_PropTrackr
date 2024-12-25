Feature: Edit profile
    As a user
    I want to edit profile information

    Scenario: Editing profile information (with confirmation)
        Given I am logged in
        And I visit "edit" page
        And I update profile with new information
        When I submit profile information
        Then I should see a confirmation message
    
    Scenario: Editing profile information (with wrong data)
        Given I am logged in
        And I visit "edit" page
        And I update my profile with invalid information
        When I submit profile information
        Then I should see a error message

    Scenario: Editing other users profile information as admin
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | false| false|
            | 2   | user2@example.com  | "password123"| Admin | Tamm | true| false|
        And I am logged in as admin
        And I visit "users" page
        And I click edit user
        And I update profile with new information
        When I submit profile information
        Then I should see admin confirmation message
        And I should see users list
    
     Scenario: Editing other users profile information as non-admin
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | false| false|
            | 2   | user2@example.com  | "password123"| Admin | Tamm | true| false|
        And I am logged in
        When I visit "other_user" page
        Then I should see not allowed message

    
