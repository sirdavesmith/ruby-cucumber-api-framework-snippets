Feature: Hosts
  Background:
    Given Default Company Exists

    Scenario Outline: Add hosts to Properties
      Given I have created property <propName>
      When I create an <hostType> host named <hostName>
      Then I should get a 201 Created status code
      @smoke @sftp
      Examples:
        | hostType    | hostName   | propName  |
        | cdn      | Cdnhost | PropertyWeb   |
        | SFTP        | SFTPhost   | PropertySFTP  |

      Examples:
        | hostType    | hostName        | propName  |
        | cdn      | Company Hosted  | PropertyWeb   |
        | SFTP        | SFTPhost        | PropertyWeb   |
        | cdn      | Cdnhost      | PropertyMobile   |
        | cdn      | Cdnhost      | PropertyAnalytics |

    Scenario: I add a host with an invalid type
       Given I have created property PropertyWeb
       When I create an invalid host named what?
       Then I should get a 400 status with a "schema-validation-error" error code
