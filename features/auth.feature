Feature: Login
    As a user
    I want to be able to log in

    Scenario: Login with correct credentials
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com | "password123"| Tiiu | Tamm | false| false|
        And I visit the login page
        And I entered the correct details
        When I submit the login form
        Then I should see the welcome message
    
    Scenario: Login with incorrect credentials
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com | "password123"| Tiiu | Tamm | false| false|
        And I visit the login page
        And I entered wrong password "123"
        When I submit the login form
        Then I should see error message

Feature: Register
    As a user
    I want to be able to register an account

    Scenario: Register with correct credentials
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com | "password123"| Tiiu | Tamm | false| false|
        And I visit the register page
        And I entered the email "newuser@example.com", password "password123", firstname "Tiina", lastname "Tamm"
        When I submit the register form
        Then I should see confirmation message
    
    Scenario: Register with incorrect credentials
        Given I visit the register page
        And I entered the email "user1@example.com", password " ", firstname "Tiina", lastname "Tamm"
        When I submit the register form
        Then I should see cant be blank message
    

Feature: Logout
    As a user
    I want to be able to logout an account

    Scenario: Logged in user successfully logging out
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com | "password123"| Tiiu | Tamm | false| false|
        And I visit the login page
        And I entered the correct details
        And I submit the login form
        When I log out
        Then I should be logged out
    
    Scenario: Unauthenticated user cannot log out
        When I visit the main page
        Then I should not see log out button

 