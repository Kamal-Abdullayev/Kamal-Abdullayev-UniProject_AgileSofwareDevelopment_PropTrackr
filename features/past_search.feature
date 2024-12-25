Feature: Access past search
    As a customer
    I want to see a list of 5 recent searches
    So that I can easily access them

    Scenario: Seeing past searches
        When I am logged in
        And I am on the home page
        When I open enter the search keyword "random"
        Then I should see the random in the recent searches list

