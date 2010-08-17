Feature: Subscribing to newsletter
  In order to get news daily
  As a guest
  I want to manage my subscription

  Scenario: Submitting email successfully
    Given I am on the homepage
    When I fill in "email" with "test@test.com"
      And I press "→"
    Then I should see "Mail dodany do bazy! Instrukcje dotyczące aktywacji właśnie wylądowały w Twojej skrzynce."
      And I should receive activation email

  Scenario: Submitting email unsuccessfully
    Given I am on the homepage
    When I fill in "email" with "omg"
      And I press "→"
    Then I should see "Podany email jest nieprawidłowy!"
    When I fill in "email" with "mike@test.com"
      And I press "→"
      And I fill in "email" with "mike@test.com"
      And I press "→"
    Then I should see "Podany email już istnieje w bazie!"

  Scenario: Confirming email successfully
    Given I have submitted email "tester@test.com"
    When I open the confirmation link
    Then I should see "Email został aktywowany."

  Scenario: Trying to confirm an email twice
    Given I have submitted email "twice@test.com"
    When I open the confirmation link
    Then I should see "Email został aktywowany."
    When I open the confirmation link
    Then I should see "Być może Twoje konto jest już aktywne."

  Scenario: Confirming email unsuccessfully
    Given I am on the homepage
    When I go to confirmation page with wrong email
    Then I should see "Ups, nie mamy w bazie takiego maila!"
    When I go to the homepage
      And I fill in "email" with "wrong@confirmation.hsh"
      And I press "→"
      And I go to confirmation page with wrong confirmation hash
    Then I should see "Klucz aktywujący nie pasuje do Twojego maila."
