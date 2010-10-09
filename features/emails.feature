# encoding: utf-8
Feature: Subscribing to newsletter
  In order to get news daily
  As a guest
  I want to manage my subscription

  Scenario: Submitting email successfully
    Given I am on the homepage
    When I fill in "email" with "test@test.com"
      And I press "Wchodzę w to!"
    Then I should see "Mail dodany do bazy! Instrukcje dotyczące aktywacji właśnie wylądowały w Twojej skrzynce."
      And I should receive activation email

  Scenario: Submitting email unsuccessfully
    Given I am on the homepage
    When I fill in "email" with "omg"
      And I press "Wchodzę w to!"
    Then I should see "Podany email jest nieprawidłowy!"
    When I fill in "email" with "mike@test.com"
      And I press "Wchodzę w to!"
      And I fill in "email" with "mike@test.com"
      And I press "Wchodzę w to!"
    Then I should see "Podany email już istnieje w bazie!"

  Scenario: Confirming email successfully
    Given I have submitted email "tester@test.com"
    When I open the confirmation link
    Then I should see "Email został aktywowany."
      And I should receive email that confirms activation

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
      And I press "Wchodzę w to!"
      And I go to confirmation page with wrong confirmation hash
    Then I should see "Klucz aktywujący nie pasuje do Twojego maila."

  Scenario: Unsubscribing email successfully
    Given I have confirmed email "sth@sth.pl"
    When I open the unsubscribe link
    Then I should see "Twoja subskrypcja została anulowana."

  Scenario: Trying to unsubscribe an email twice
    Given I have confirmed email "twiceunsubscribe@sth.pl"
    When I open the unsubscribe link
    Then I should see "Twoja subskrypcja została anulowana."
    When I open the unsubscribe link
    Then I should see "Ups, nie mamy w bazie takiego maila!"

  Scenario: Unsubscribing email unsuccessfully
    Given I am on the homepage
    When I go to unsubscribe page with wrong email
    Then I should see "Ups, nie mamy w bazie takiego maila!"
    Given I have confirmed email "wrong@unsubscribe.com"
    When I go to unsubscribe page with wrong confirmation hash
    Then I should see "Klucz aktywujący nie pasuje do Twojego maila."
