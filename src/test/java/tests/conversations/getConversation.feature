Feature: test cases to get conversation by ID API

  Background:
    # deleting all existing conversations
    * def res = call read(reusableFeatures + 'common.feature@getConversations')
    * def res = karate.jsonPath(res.response, "$._embedded.conversations.*.uuid")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteConversation', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for get conversation by id api
     # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    # 'hitting get conversation by id api with invalid token'
    * call read(reusableFeatures + 'common.feature@getConversation') {newAuth : 'dummyAuth' , id : #(conOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting get conversation by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id), newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is not able to get deleted conversation
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

      # 'hitting get conversation by id api with valid token and verifying status code'
    * def getCon =  call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id), status : 404}
    * match getCon.response == read(conversationResponses + 'conversationNotFound.json')


  Scenario: verify user is not able to get conversations that have expired its TTL time
    # creating a conversation with 3 sec as ttl
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}

    # waiting for 3 seconds
    * commonUtil.sleep(3)

    # 'hitting get conversation by id api with valid token and verifying status code'
    * def getCon =  call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id), status : 404}
    * match getCon.response == read(conversationResponses + 'conversationNotFound.json')

  Scenario: verify user is able to get conversations that have expired its initial TTL time if its ttl was extended before expiry
    # creating a conversation with 3 sec as ttl
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}

    # updating the created conversation
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}

    # waiting for 3 seconds
    * commonUtil.sleep(3)

    # get the created conversation
    * call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is  able to get the latest conversation data after update
    # creating conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def conGetOne = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    # updating the created conversation
    * def conUpdate = call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}
    * def conGetTwo = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    * match conGetOne.response.uuid == conGetTwo.response.uuid
    * match conGetOne.response.name != conGetTwo.response.name
    * match conGetOne.response.display_name != conGetTwo.response.display_name
    * match conGetOne.response.properties.ttl != conGetTwo.response.properties.ttl

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

    Scenario: validate json schema for get conversation by id api
      # creating a conversation
      * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # get the created conversation
      * def conGet = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}
      * match conGet.response == read(conversationSchemas + 'getConversationById.json')

    # deleting created conversation
      * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}


