Feature: test cases for update conversations API

  Scenario: verify invalid and valid jwt response for update conversations api
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    # 'hitting update conversations api with invalid token'
    * call read(reusableFeatures + 'common.feature@updateConversation') {newAuth : 'asdf' , id : #(conOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting update conversations api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id), newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is able to update conversation by passing valid values in body
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def conOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}
    # 'hitting update conversations api with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}
    * def conOneAfterUpdate = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    * match conOneBeforeUpdate.response.uuid == conOneAfterUpdate.response.uuid
    * match conOneBeforeUpdate.response.name != conOneAfterUpdate.response.name
    * match conOneBeforeUpdate.response.display_name != conOneAfterUpdate.response.display_name
    * match conOneBeforeUpdate.response.properties.ttl != conOneAfterUpdate.response.properties.ttl

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is not able to update conversation by passing invalid values in body
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def conOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    # 'hitting update conversations api with invalid body and verifying status code'
    * def value = conversationById
    * replace value.conversation_id = conOne.response.id
    * def body = read(conversationPayloads + 'createConversationAllInValid.json')
    * call read(baseCalls + '@put') {path: #(value), content : #(body), status : 400}

     # validating error response
    * match response == read(conversationResponses + 'createConversationAllInValid.json')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 200}

  Scenario: verify user is not able to update conversation by passing invalid conversation id in path param
    # 'hitting update conversations api with invalid body and verifying status code'
    * def value = conversationById
    * replace value.conversation_id = 'dummyId'
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * call read(baseCalls + '@put') {path: #(value), content : #(body), status : 404}

     # validating error response
    * match response == read(conversationResponses + 'conversationNotFound.json')

  Scenario: verify user is not able to udpate conversation that is expired due to TTL
      # creating a conversation with 3 sec as ttl
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}

    # verifying the created conversation is present
    * call read(baseCalls + '@get') {path: #(conversations) }
    * match response.count == 1

    # waiting for 3 seconds
    * commonUtil.sleep(3)
    * call read(baseCalls + '@get') {path: #(conversations) }

    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id), status:404}
    # validating error response
    * match response == read(conversationResponses + 'conversationNotFound.json')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 404}

  Scenario: verify user is not able to update deleted conversation
      # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # verifying the created conversation is present
    * call read(baseCalls + '@get') {path: #(conversations) }
    * match response.count == 1

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id), status:404}
    # validating error response
    * match response == read(conversationResponses + 'conversationNotFound.json')

  Scenario: verify user is able to update same conversation multiple times
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def conOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}
    # 'hitting update conversations api with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}
    * def conOneAfterUpdate = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    * match conOneBeforeUpdate.response.uuid == conOneAfterUpdate.response.uuid
    * match conOneBeforeUpdate.response.name != conOneAfterUpdate.response.name
    * match conOneBeforeUpdate.response.display_name != conOneAfterUpdate.response.display_name
    * match conOneBeforeUpdate.response.properties.ttl != conOneAfterUpdate.response.properties.ttl

    # 'hitting update conversations api again with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}
    * def conOneAfterUpdate2 = call read(reusableFeatures + 'common.feature@getConversation') {id : #(conOne.response.id)}

    * match conOneAfterUpdate2.response.uuid == conOneAfterUpdate.response.uuid
    * match conOneAfterUpdate2.response.name != conOneAfterUpdate.response.name
    * match conOneAfterUpdate2.response.display_name != conOneAfterUpdate.response.display_name

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is not able to crate duplicate conversation through update
    # creating a conversation
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * def conOne = call read(baseCalls + '@post') {path: #(conversations), content : #(body)}

    # creating a conversation
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * body.name = "con 2"
    * def conTwo = call read(baseCalls + '@post') {path: #(conversations), content : #(body)}

    # 'hitting update conversations api same values and verifying status code'
    * def value = conversationById
    * replace value.conversation_id = conTwo.response.id
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * def conUpdate = call read(baseCalls + '@put') {path: #(value), content : #(body), status : 400}

    # validating error response
    * match conUpdate.response == read(conversationResponses + 'duplicateConversation.json')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 200}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conTwo.response.id), status : 200}

