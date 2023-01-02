Feature: test cases for list conversation API

  Background:
    # deleting all existing conversations
    * def res = call read(reusableFeatures + 'common.feature@getConversations')
    * def res = karate.jsonPath(res.response, "$._embedded.conversations.*.uuid")
    * def fun = function(arg){ for (let i = 0; i < arg.length; i++) { karate.call(reusableFeatures + 'common.feature@deleteConversation', {id: arg[i]})}}
    * call fun res

  Scenario: verify invalid and valid jwt response for conversations list api
    # 'hitting list conversations api with invalid token'
    * call read(baseCalls + '@get') {path: #(conversations) , newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting list conversations api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(conversations) , newAuth : #(auth), status : 200}

  Scenario: verify conversation list api when no conversations are available
    # 'hitting list conversations api with invalid token'
    * call read(baseCalls + '@get') {path: #(conversations) }
    # validating schema
    * match response == read(conversationSchemas + 'noConversations.json')

  Scenario: verify page size and record index has default values when no params are passed
    # 'hitting list conversations api with invalid token'
    * call read(baseCalls + '@get') {path: #(conversations) }
    # validating response fields for page size record index and count
    * match response.count == 0
    * match response.page_size == 10
    * match response.record_index == 0

  Scenario: verify conversation list api when conversations are available
      # creating 2 conversations
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def conTwo = call read(reusableFeatures + 'common.feature@createConversation')

    * call read(baseCalls + '@get') {path: #(conversations) }

    # validating schema
    * match response == read(conversationSchemas + '2Conversations.json')
    * match response.count == 2
    * match response.page_size == 10
    * match response.record_index == 0

      # deleting created conversations
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conTwo.response.id)}

  Scenario: verify conversation list api when user sends invalid value in page size param
    # hitting conversations list api with invalid page size param
    * def values = {page_size : -1}
    * call read(baseCalls + '@get') {path: #(conversations) , queryParams : #(values), status : 400}

    * match response ==  read(conversationResponses + 'negativePageSize.json')

  Scenario: verify conversation list api when user sends invalid value in index param
    # hitting conversations list api with invalid index param
    * def values = {record_index : -1}
    * call read(baseCalls + '@get') {path: #(conversations) , queryParams : #(values), status : 400}

    * match response ==  read(conversationResponses + 'negativeIndex.json')


  Scenario: verify conversation list api when user sends invalid value in order param
    # hitting conversations list api with invalid order param
    * def values = {order : -1}
    * call read(baseCalls + '@get') {path: #(conversations) , queryParams : #(values), status : 400}

    * match response ==  read(conversationResponses + 'invalidOrder.json')

  Scenario: verify user is not able to get deleted conversations
      # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    * call read(baseCalls + '@get') {path: #(conversations) }

    * match response.count == 1

      # deleting created conversations
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

    * call read(baseCalls + '@get') {path: #(conversations) }
    # verifying the deleted conversation is not present
    * match response.count == 0

# commenting out as this is making other test cases to fail
#  Scenario: verify user is not able to get conversation that is ttl expired
#      # creating a conversation with 3 sec as ttl
#    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}
#
#    # verifying the created conversation is present
#    * call read(baseCalls + '@get') {path: #(conversations) }
#    * match response.count == 1
#
#    # waiting for 3 seconds
#    * commonUtil.sleep(3)
#    * call read(baseCalls + '@get') {path: #(conversations) }
#
#    # verifying the expired conversation is not present
#    * match response.count == 0

  Scenario: verify user is able to fetch latest set of conversations when a new conversation is added / removed
    * call read(baseCalls + '@get') {path: #(conversations) }
    * match response.count == 0

    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # verifying the created conversation is present
    * call read(baseCalls + '@get') {path: #(conversations) }
    * match response.count == 1

    #deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

    * call read(baseCalls + '@get') {path: #(conversations) }
    # verifying the deleted conversation is not present
    * match response.count == 0