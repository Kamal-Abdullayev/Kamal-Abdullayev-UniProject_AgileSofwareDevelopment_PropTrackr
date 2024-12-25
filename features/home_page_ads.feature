Feature: Home Page Advertisements
  As a customer
  I want to see some advertisements when I open the page

  Scenario: Navigate to advertisement detail page
    Given I am on the home page
    When I click the "Learn More" button for an advertisement
    Then I should see the detail page for that advertisement

