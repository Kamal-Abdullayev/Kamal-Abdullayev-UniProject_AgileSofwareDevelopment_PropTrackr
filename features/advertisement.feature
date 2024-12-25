Feature: Manage Advertisements
  As a user
  I want to be able to create, edit, and delete advertisements on the platform.

Scenario: Creating an advertisement and listing it
    Given the following users exist:
            | id  | email              | password | firstname | lastname|
            | 1   | user1@example.com  | "password123"| Tiiu | Tamm | 
            | 2   | user2@example.com  | "password123"| Tiina | Tamm |
    And the following locations exist:
        | country  | city    | area     |
        | Estonia  | Tallinn | Kesklinn |
        | Estonia  | Tartu   | Kesklinn |
        | Finland  | Helsinki | Kallio  |
    And I am logged in
    And I navigate to the new advertisement form
    And I fill in the advertisement form with:
            | title             | description           | price  | square_meters | rooms | floor | total_floors | phone_number    | street |
            | Cozy Apartment    | Spacious 2-bedroom    | 1200   | 80            | 2     | 3     | 5            | +372 2222 2222  | Raatuse |

    And I submit the form.
    Then I should see a success message
    When I navigate to the advertisements page
    Then I should see the advertisement in the list

Scenario: Editing an existing advertisement
    Given I am logged in
    And the following locations exist:
        | country  | city    | area     |
        | Estonia  | Tallinn | Kesklinn |
        | Estonia  | Tartu   | Kesklinn |
        | Finland  | Helsinki | Kallio  |
    And there is an existing advertisement
    And I navigate to edit advertisement
    And I update the advertisement form with new data
    And I submit the form
    Then I should see an update success message

Scenario: Deleting an advertisement
    Given I am logged in
    And the following locations exist:
        | country  | city    | area     |
        | Estonia  | Tallinn | Kesklinn |
        | Estonia  | Tartu   | Kesklinn |
        | Finland  | Helsinki | Kallio  |
    And there is an existing advertisement
    When I delete the advertisement
    Then I should see a deletion success message
    And I should not see the advertisement in the list

Scenario: View an advertisement with recommendations
    Given there is an advertisement with type "Rent" priced at "1200" having "3" rooms and "80" square meters
    And there are similar advertisements available
    When I view the advertisement detail page
    Then I should see the advertisement details
    And I should see up to "5" recommended advertisements

Scenario: View an advertisement without recommendations
    Given there is an advertisement with type "Rent" priced at "1200" having "3" rooms and "80" square meters
    When I view the advertisement detail page
    Then I should see the advertisement details
    And I should see no recommended advertisements

Scenario: Change state to Reserved
      Given I am logged in
      And the following locations exist:
        | country  | city    | area     |
        | Estonia  | Tallinn | Kesklinn |
        | Estonia  | Tartu   | Kesklinn |
        | Finland  | Helsinki | Kallio  |
      And there is an existing advertisement
      And I navigate to the advertisement edit page to change state
      And I update the state to reserved
      When I submit the form
      Then I should see a state update success message


Scenario: View recommended price when updating
      Given I am logged in
      And there is an existing advertisement
      When I navigate to edit advertisement
      Then I should be able to click on recommended price button


      
      


    



