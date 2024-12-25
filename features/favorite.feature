Feature: Add to favorites
    As a logged in user
    I want to save properties to a favorites list

    Scenario: Adding property to favorite list
        Given following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
        And the following advertisements exist:
            | id  | title          | description  | price | type  | recommended_price | square_meters | city | area | country | street | user_id  |
            | 1   | Test property  | Test desc    | 100   | Rent  | 150.0             | 50            | Tartu | Kesklinn | Estonia | ülikooli | 1 |
            | 2   | Test property2 | Test desc2   | 200   | Rent  | 180.0             | 70            | Tartu | Kesklinn | Estonia | ülikooli | 2 |
        And I am logged in
        And I visit "main" page
        When I click on add to favorite
        Then I should see a confirmation message for added to favorites
 
    Scenario: Removing property from favorite list
        Given following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
        And the following advertisements exist:
            | id  | title          | description  | price | type  | recommended_price | square_meters | city | area | country | street | user_id  |
            | 1   | Test property  | Test desc    | 100   | Rent  | 150.0             | 50            | Tartu | Kesklinn | Estonia | ülikooli | 1 |
            | 2   | Test property2 | Test desc2   | 200   | Rent  | 180.0             | 70            | Tartu | Kesklinn | Estonia | ülikooli | 2 |
        And I am logged in
        And I visit "main" page
        When I click on add to favorite twice
        Then I should see a confirmation message for removed from favorites

    Scenario: Unauthenticated user adding to favorites
        Given following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
        And the following advertisements exist:
            | id  | title          | description  | price | type  | recommended_price | square_meters | city | area | country | street | user_id  |
            | 1   | Test property  | Test desc    | 100   | Rent  | 150.0             | 50            | Tartu | Kesklinn | Estonia | ülikooli | 1 |
            | 2   | Test property2 | Test desc2   | 200   | Rent  | 180.0             | 70            | Tartu | Kesklinn | Estonia | ülikooli | 2 |
        And I visit "main" page
        And I should not see favorites button

    Scenario: Authenticated user seeing favorites
        Given following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
        And the following advertisements exist:
            | id  | title          | description  | price | type  | recommended_price | square_meters | city | area | country | street | user_id  |
            | 1   | Test property  | Test desc    | 100   | Rent  | 150.0             | 50            | Tartu | Kesklinn | Estonia | ülikooli | 1 |
            | 2   | Test property2 | Test desc2   | 200   | Rent  | 180.0             | 70            | Tartu | Kesklinn | Estonia | ülikooli | 2 |
        And I am logged in
        And I visit "main" page
        And I click on add to favorite
        When I visit "favorite" page
        Then I should see favorite ad
