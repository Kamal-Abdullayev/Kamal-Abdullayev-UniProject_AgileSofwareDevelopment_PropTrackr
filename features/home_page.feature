Feature: Home Page Auth buttons
    As a customer
    I want to see a home page with the login/register button

    Scenario: Unauthenticated user Register/Login available
        When I open the app
        Then I should see a register-login button


Feature: Home Page Search field
    As a customer
    I want to see a home page with the search field

    Scenario: Unauthenticated seeing search field
        When I open the app
        Then I should see a search form

