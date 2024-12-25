Feature: Block user
    As an admin
    I want to block users

    Scenario: Blocked user not able to create ads
        Given following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | true| true|
        And I am logged in as blocked user
        When I visit "main" page
        Then I should see a restriction message

    Scenario: Admin blocking user
        Given following users exist:
            | id  | email              | password | firstname | lastname| is_admin| is_blocked|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | true| false|
        And I am logged in as admin
        And I visit "users" page
        When I click block
        Then I should see confirmation message
