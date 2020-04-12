Feature: Cleanup properties after test runs
  Background:
    Given Default Company Exists

  @smoke
  Scenario: Remove Test Properties for this test run
    Given I delete all properties in storage

  @jenkins
  Scenario: Remove properties over 2 hours old
    Given I remove Test Properties over 2 hours old
