Feature: Hide Sold/Rented Properties
    As a user
    I want to see only available properties
    Scenario: Searching for unavailable property
        Given the following advertisements exist for search:
        | title                         | description                                        | price   | type   | square_meters | location                   | rooms | floor | total_floors | reference                              | state       | country  | city      | area       |
        | Modern Apartment in Kesklinn  | A modern 2-bedroom apartment in the heart of Tallinn. | 150000  | Rent   | 60            | Kesklinn, Tallinn, Estonia | 2     | 3     | 5            | 4c3e296e-909f-4d48-9bc6-ca09cbb6fe90 | Unavailable   | Estonia  | Tallinn   | Kesklinn   |
        And I visit search page
        When I submit search properties
        Then I should not find results

