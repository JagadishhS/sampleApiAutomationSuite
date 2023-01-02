Feature: test cases to get user by ID API

  Background:
    # deleting all existing users
    * def res = call read(reusableFeatures + 'common.feature@getUsers')
    * def res = karate.jsonPath(res.response, "$.*.id")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteUser', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for get user by id api
     # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    # 'hitting get user by id api with invalid token'
    * call read(reusableFeatures + 'common.feature@getUser') {newAuth : 'dummyAuth' , id : #(userOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting get user by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id), newAuth : #(auth), status : 200}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to get deleted user
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

      # 'hitting get user by id api with valid token and verifying status code'
    * def getCon =  call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id), status : 404}
    * match getCon.response == read(userResponses + 'userNotFound.json')

  Scenario: verify user is  able to get the latest user data after update
    # creating user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userGetOne = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    # updating the created user
    * def userUpdate = call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id)}
    * def userGetTwo = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    * match userGetOne.response.id == userGetTwo.response.id
    * match userGetOne.response.name != userGetTwo.response.name
    * match userGetOne.response.display_name != userGetTwo.response.display_name

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

    Scenario: validate json schema for get user by id api
      # creating a user
      * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    # get the created user
      * def userGet = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}
      * match userGet.response == read(userSchemas + 'getUserById.json')

    # deleting created user
      * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}


