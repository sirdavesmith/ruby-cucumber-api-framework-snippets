Feature: Companies
  Scenario: Create the Default company
    When I create the default company
    Then the company_id is set
