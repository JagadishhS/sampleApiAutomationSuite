Feature: test cases to delete user by ID API

  Background:
    # deleting all existing users
    * def res = call read(reusableFeatures + 'common.feature@getUsers')
    * def res = karate.jsonPath(res.response, "$.*.id")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteUser', {id: arg[i]})}}
    * call fun res


  Scenario: verify invalid and valid jwt response for delete user by id api
     # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    # 'hitting delete user by id api with invalid token'
    * call read(reusableFeatures + 'common.feature@deleteUser') {newAuth : 'dummyAuth' , id : #(userOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting delete user by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id), newAuth : #(auth), status : 200}

  Scenario: verify schema of delete user
     # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

      # delete user
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}
    * match conDelete.response == {}

  Scenario: verify user is not able to delete user with invalid user id
     # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

      # delete user with invalid id
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteUser') {id : #(dummyId), status : 404}
    # validating error response
    * match conDelete.response == read(userResponses + 'userNotFound.json')

      # delete user
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id), status : 200}

  Scenario: verify user is not able to delete a user that is deleted already
       # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

      # delete user
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

    # deleting created user
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id), status : 404}
    # validating error response
    * match conDelete.response == read(userResponses + 'userNotFound.json')