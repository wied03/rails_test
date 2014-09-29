Feature: Search

  Scenario: Find what I'm looking for
    Given I am on the Google search page
    When I search for "cucumber github"
    Then I should see
      """
      GitHub
      """