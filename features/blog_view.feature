Feature: View blogs

  @selenium
  Scenario: No existing blogs
    Given I am on the "/blogs/index" page
    Then I should see
      """
      I have updated the application and it should restart automatically
      """
