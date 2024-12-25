Feature: Not interested feature
    As a customer
    I want to search ads

    Scenario: Authenticated user marks ad as not interested
        Given the following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
        And the following locations exist:
            | country  | city    | area     |
            | Estonia  | Tallinn | Kesklinn |
            | Estonia  | Tartu   | Kesklinn |
            | Finland  | Helsinki | Kallio  |
        And there is an existing available advertisement
        And I am logged in
        When I am on main page
        Then I should see not interested button
