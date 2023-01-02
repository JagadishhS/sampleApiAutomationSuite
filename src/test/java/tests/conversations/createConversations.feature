Feature: test cases for create conversations API

  Background:
    # deleting all existing conversations
    * def res = call read(reusableFeatures + 'common.feature@getConversations')
    * def res = karate.jsonPath(res.response, "$._embedded.conversations.*.uuid")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteConversation', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for create conversations api
    # 'hitting create conversations api with invalid token'
    * call read(baseCalls + '@post') {path: #(conversations) , content : {}, newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting create conversations api with valid token and verifying status code'
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') { newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id),newAuth : #(auth), status : 200}

  Scenario: verify schema of create conversations with all valid inputs in body
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * match conOne.response == read(conversationSchemas + 'createConversations.json')
    
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify schema of create conversations with all invalid inputs in body
    * def body = read(conversationPayloads + 'createConversationAllInValid.json')
    * call read(baseCalls + '@post') {path: #(conversations), content : #(body),status : 400}

    # validating error response
    * match response == read(conversationResponses + 'createConversationAllInValid.json')

    # verify no conversations created
    * call read(baseCalls + '@get') {path: #(conversations),status : 200 }
    * match response.count == 0

  Scenario: verify user is not able to create duplicate conversations
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * def conOne = call read(baseCalls + '@post') {path: #(conversations), content : #(body)}
    * call read(baseCalls + '@post') {path: #(conversations), content : #(body), status : 400}

    # validating error response
    * match response == read(conversationResponses + 'duplicateConversation.json')

    # verify duplicate conversation not created
    * call read(baseCalls + '@get') {path: #(conversations),status : 200 }
    * match response.count == 1

     # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is able to create conversation with empty body
    * def body = {}
    * def conOne = call read(baseCalls + '@post') {path: #(conversations), content : #(body)}

    # verify conversation created
    * call read(baseCalls + '@get') {path: #(conversations),status : 200 }
    * match response.count == 1

     # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

