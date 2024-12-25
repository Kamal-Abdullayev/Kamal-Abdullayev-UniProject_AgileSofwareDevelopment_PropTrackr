Feature: Delete user
    As a user
    I want to delete an account

    Scenario: Authenticated user deleting own account
        Given I am logged in
        And I visit "settings" page
        And I choose to delete my account
        When I confirm deletion
        Then I should see a confirmation message of account deletion
    
    Scenario: Authenticated user starting deletion and cancelling
        Given I am logged in
        And I visit "settings" page
        And I choose to delete my account
        When I cancel deletion
        Then I should still be on settings page
    
    Scenario: Admin user deleting someone elses account
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | false| false|
            | 2   | user2@example.com  | "password123"| Admin | Tamm | true| false|
        And I am logged in as admin
        And I visit "users" page
        And I click delete
        Then I should see a confirmation message of account deletion
    
    Scenario: Non-admin user deleting someone elses account (unsuccessfully)
        Given the following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | false| false|
            | 2   | user2@example.com  | "password123"| Admin | Tamm | true| false|
        And I am logged in
        And I visit "users/delete" page
        Then I should not have access

    
        