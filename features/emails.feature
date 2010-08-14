Feature: Subscribing to newsletter
  In order to get news daily
  As a guest
  I want to manage my subscription

  Scenario: Submitting email successfully
    Given I am on the homepage
    When I fill in "email" with "test@test.com"
      And I press "→"
    Then I should see "Mail dodany do bazy! Instrukcje dotyczące aktywacji właśnie wylądowały w Twojej skrzynce."

  Scenario: Submitting email unsuccessfully
    Given I am on the homepage
    When I fill in "email" with "omg"
      And I press "→"
    Then I should see "Podany email już istnieje w bazie lub jest nieprawidłowy."
    When I fill in "email" with "mike@test.com"
      And I press "→"
      And I fill in "email" with "mike@test.com"
      And I press "→"
    Then I should see "Podany email już istnieje w bazie lub jest nieprawidłowy."