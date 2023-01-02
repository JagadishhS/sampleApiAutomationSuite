Feature: test cases for update users API

  Background:
    # deleting all existing users
    * def res = call read(reusableFeatures + 'common.feature@getUsers')
    * def res = karate.jsonPath(res.response, "$.*.id")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteUser', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for update users api
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    # 'hitting update users api with invalid token'
    * call read(reusableFeatures + 'common.feature@updateUser') {newAuth : 'dummyAuth' , id : #(userOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting update users api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id), newAuth : #(auth), status : 200}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is able to update user by passing valid values in body
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}
    # 'hitting update users api with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id)}
    * def userOneAfterUpdate = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    * match userOneBeforeUpdate.response.id == userOneAfterUpdate.response.id
    * match userOneBeforeUpdate.response.name != userOneAfterUpdate.response.name
    * match userOneBeforeUpdate.response.display_name != userOneAfterUpdate.response.display_name

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to update user by passing invalid values in body
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    # 'hitting update users api with invalid body and verifying status code'
    * def value = userById
    * replace value.user_id = userOne.response.id
    * def body = read(userPayloads + 'createUserAllInValid.json')
    * call read(baseCalls + '@put') {path: #(value), content : #(body), status : 400}

     # validating error response
    * match response == read(userResponses + 'createUserAllInValid.json')

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id), status : 200}

  Scenario: verify user is not able to update user by passing invalid user id in path param
    # 'hitting update users api with invalid body and verifying status code'
    * def value = userById
    * replace value.user_id = 'dummyId'
    * def body = read(userPayloads + 'createUserAllValid.json')
    * call read(baseCalls + '@put') {path: #(value), content : #(body), status : 404}

     # validating error response
    * match response == read(userResponses + 'userNotFound.json')

  Scenario: verify user is not able to update deleted user
      # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    # verifying the created user is present
    * call read(baseCalls + '@get') {path: #(users) }
    * match response == '#[1]'

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

    * call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id), status:404}
    # validating error response
    * match response == read(userResponses + 'userNotFound.json')

  Scenario: verify user is able to update same user multiple times
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}
    # 'hitting update users api with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id)}
    * def userOneAfterUpdate = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    * match userOneBeforeUpdate.response.id == userOneAfterUpdate.response.id
    * match userOneBeforeUpdate.response.name != userOneAfterUpdate.response.name
    * match userOneBeforeUpdate.response.display_name != userOneAfterUpdate.response.display_name

    # 'hitting update users api again with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id)}
    * def userOneAfterUpdate2 = call read(reusableFeatures + 'common.feature@getUser') {id : #(userOne.response.id)}

    * match userOneAfterUpdate2.response.id == userOneAfterUpdate.response.id
    * match userOneAfterUpdate2.response.name != userOneAfterUpdate.response.name
    * match userOneAfterUpdate2.response.display_name != userOneAfterUpdate.response.display_name

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to crate duplicate user through update
    # creating a user
    * def body = read(userPayloads + 'createUserAllValid.json')
    * def userOne = call read(baseCalls + '@post') {path: #(users), content : #(body)}

    # creating a user
    * def body = read(userPayloads + 'createUserAllValid.json')
    * body.name = "con 2"
    * def userTwo = call read(baseCalls + '@post') {path: #(users), content : #(body)}

    # 'hitting update users api same values and verifying status code'
    * def value = userById
    * replace value.user_id = userTwo.response.id
    * def body = read(userPayloads + 'createUserAllValid.json')
    * def userUpdate = call read(baseCalls + '@put') {path: #(value), content : #(body), status : 400}

    # validating error response
    * match userUpdate.response == read(userResponses + 'duplicateUser.json')

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id), status : 200}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userTwo.response.id), status : 200}

  Scenario: verify the response schema after update
    # creating a user
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    # verifying the created user is present
    * call read(baseCalls + '@get') {path: #(users) }
    * match response == '#[1]'

    * def userUpdate = call read(reusableFeatures + 'common.feature@updateUser') {id : #(userOne.response.id)}
    # validating response Schema
    * match userUpdate.response == read(userSchemas + 'createUsers.json')

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}