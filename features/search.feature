Feature: Search feature
    As a customer
    I want to search ads

    Scenario: Unauthenticated user searching available properties
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
        When I am on main page
        Then I should see this ad

    Scenario: Authenticated user searching available properties by selecting type and country
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
        When I am on search page
        Then I can select type
        And I can select country
        When I submit search
        Then I should see the advertisement

    Scenario: Search can be filtered by price range, number of rooms range and city areas
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
        When I am on search page
        Then I can choose price, number of rooms and city areas
