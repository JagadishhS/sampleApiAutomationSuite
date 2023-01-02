Feature: test cases for list users API

  Background:
    # deleting all existing users
    * def res = call read(reusableFeatures + 'common.feature@getUsers')
    * def res = karate.jsonPath(res.response, "$.*.id")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteUser', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for users list api
    #'hitting list users api with invalid token'
    * call read(baseCalls + '@get') {path: #(users) , newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting list users api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(users) }

  Scenario: verify user list api when no users are available
    * call read(baseCalls + '@get') {path: #(users) }
    # validating schema
    * match response == []

  Scenario: verify user list api when users are available
      # creating 2 users
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userTwo = call read(reusableFeatures + 'common.feature@createUser')

    * call read(baseCalls + '@get') {path: #(users) }

    # validating schema
    * match response == read(userSchemas + '2users.json')

      # deleting created users
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userTwo.response.id)}

  Scenario: verify user is able to fetch latest set of users when a new user is added / removed

    * call read(baseCalls + '@get') {path: #(users) }
    * match response == '#[0]'

    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    # verifying the created user is present
    * call read(baseCalls + '@get') {path: #(users) }
    * match response == '#[1]'

    #deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

    * call read(baseCalls + '@get') {path: #(users) }
    # verifying the deleted user is not present
    * match response == '#[0]'