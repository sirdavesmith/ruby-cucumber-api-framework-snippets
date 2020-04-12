Feature: Properties
  Background:
    Given Default Company Exists

  @smoke
  Scenario: Create PropertyOne
    Given I create property PropertyWeb for web
    Then I should get a 201 Created status code
    And the response is valid according to the "property" schema
    And the attributes match:
      """
      {
        "platform": "web",
        "enabled": true,
        "undefined_vars_return_empty": false
      }
      """
  @smoke
  Scenario: Create PropertyTwo
    Given I create property PropertyMobile for mobile
    Then I should get a 201 Created status code
    And the response is valid according to the "property" schema
    And the attributes match:
      """
      {
        "platform": "mobile",
        "ssl_enabled": true,
        "privacy": "optedin"
      }
      """

  Scenario: Create PropertyThree
    Given I create property PropertyAnalytics for web
    Then I should get a 201 Created status code
    And the response is valid according to the "property" schema

  Scenario: Create and delete a property
    Given I create property PropertyToBeDeleted for web
    Then I should get a 201 Created status code
    When I delete the property PropertyToBeDeleted
    Then I should get a 204 Updated status code

  Scenario: Create a web Property With extra Invalid Attributes
    Given I create a PropertyFailed property with the body:
    """
    {
      "data": {
        "attributes": {
          "link_delay": 3000,
          "platform": "web",
          "domains": ["acme.com"],
          "undefined_vars_return_empty": true
        },
        "type": "properties"
      }
    }
    """
    Then I should get a 400 status with a "schema-validation-error" error code

  Scenario: Create a web Property with a missing platform
    Given I create a PropertyFailed property with the body:
    """
    {
      "data": {
        "attributes": {
          "domains": ["acme.com"],
          "undefined_vars_return_empty": true
        },
        "type": "properties"
      }
    }
    """
    Then I should get a 400 status with a "schema-validation-error" error code

  Scenario: Create a web Property with an invalid platform
    Given I create a PropertyFailed property with the body:
    """
    {
      "data": {
        "attributes": {
          "platform": "xBox",
          "domains": ["acme.com"],
          "undefined_vars_return_empty": true
        },
        "type": "properties"
      }
    }
    """
    Then I should get a 400 status with a "schema-validation-error" error code

  Scenario: Create a mobile Property with invalid SSL settings
    Given I create a PropertyFailed property with the body:
    """
    {
      "data": {
        "attributes": {
          "platform": "mobile",
          "ssl_enabled": "true",
          "privacy": "optedin"
        },
        "type": "properties"
      }
    }
    """
    Then I should get a 400 status with a "schema-validation-error" error code

  Scenario: Create a mobile Property with invalid privacy settings
    Given I create a PropertyFailed property with the body:
    """
    {
      "data": {
        "attributes": {
          "platform": "mobile",
          "ssl_enabled": true,
          "privacy": "maybe"
        },
        "type": "properties"
      }
    }
    """
    Then I should get a 400 status with a "schema-validation-error" error code


  Scenario Outline: Delete properties
    Given I have created property <propName>
    And I delete the property <propName>
    Then I should get a 204 Updated status code
    Examples:
      | propName |
