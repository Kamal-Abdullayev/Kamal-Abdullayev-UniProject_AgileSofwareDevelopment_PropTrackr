Feature: Change Password
  As a user
  I want to change my password
  So that I can keep my account secure

  Scenario: Successfully change password
    Given a user with email "john.doe@example.com" and password "valid_old_password" exists
    And I am logged in as "john.doe@example.com"
    When I change my password with old password "valid_old_password" and new password "new_secure_password"
    Then I should see a confirmation message "Password updated successfully."
    And my password should be updated to "new_secure_password"

  Scenario: Fail to change password with incorrect old password
    Given a user with email "john.doe@example.com" and password "valid_old_password" exists
    And I am logged in as "john.doe@example.com"
    When I change my password with old password "wrong_password" and new password "new_secure_password"
    Then I should see an error message "There was an error updating your password."
    And my password should remain unchanged
