Feature: base api calls

  Background: Default needs to load for every scenario
    * url baseUrl
    * def headers =  {body-type : 'application/json', accept : '*/*',Authorization : #(auth)}
    * def params =  typeof queryParams == 'undefined' ? null : queryParams
    * def statusCode =  typeof status == 'undefined' ? 200 : status
    * def body =  typeof content == 'undefined' ? null : content
    * headers.Authorization =  typeof newAuth == 'undefined' ? auth : newAuth

  @post
  Scenario: post with given path and body
    Given path path
    And params params
    And headers headers
    And request body
    When method post
    Then match responseStatus == statusCode

  @put
  Scenario: put with given path and body
    Given path path
    And params params
    And headers headers
    And request body
    When method put
    Then match responseStatus == statusCode

  @get
  Scenario: get with given path and query
    Given path path
    And params params
    And headers headers
    When method get
    Then match responseStatus == statusCode

  @delete
  Scenario: delete with given path and query
    Given path path
    And params params
    And headers headers
    When method delete
    Then match responseStatus == statusCode

  @patch
  Scenario: patch with given path and query
    Given path path
    And params params
    And headers headers
    And request body
    When method patch
    Then match responseStatus == statusCode