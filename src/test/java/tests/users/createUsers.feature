Feature: test cases for create users API

  Background:
    # deleting all existing users
    * def res = call read(reusableFeatures + 'common.feature@getUsers')
    * def res = karate.jsonPath(res.response, "$.*.id")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteUser', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for create users api
    # 'hitting create users api with invalid token'
    * call read(baseCalls + '@post') {path: #(users) , content : {}, newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting create users api with valid token and verifying status code'
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify schema of create users with all valid inputs in body
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * match userOne.response == read(userSchemas + 'createUsers.json')
    
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify schema of create users with all invalid inputs in body
    * def body = read(userPayloads + 'createUserAllInValid.json')
    * call read(baseCalls + '@post') {path: #(users), content : #(body),status : 400}

    # validating error response
    * match response == read(userResponses + 'createUserAllInValid.json')

    # verify no users created
    * call read(baseCalls + '@get') {path: #(users),status : 200 }
    * match response == '#[0]'

  Scenario: verify user is not able to create duplicate users
    * def body = read(userPayloads + 'createUserAllValid.json')
    * def userOne = call read(baseCalls + '@post') {path: #(users), content : #(body)}
    * call read(baseCalls + '@post') {path: #(users), content : #(body), status : 400}

    # validating error response
    * match response == read(userResponses + 'duplicateUser.json')

    # verify duplicate user not created
    * call read(baseCalls + '@get') {path: #(users),status : 200 }
    * match response == '#[1]'

     # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is able to create user with empty body
    * def body = {}
    * def userOne = call read(baseCalls + '@post') {path: #(users), content : #(body)}

    # verify user created
    * call read(baseCalls + '@get') {path: #(users),status : 200 }
    * match response == '#[1]'

     # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

