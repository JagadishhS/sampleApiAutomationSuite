Feature: test cases to delete conversation by ID API

  Scenario: verify invalid and valid jwt response for delete conversation by id api
     # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    # 'hitting delete conversation by id api with invalid token'
    * call read(reusableFeatures + 'common.feature@deleteConversation') {newAuth : 'asdf' , id : #(conOne.response.id), status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting delete conversation by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), newAuth : #(auth), status : 200}

  Scenario: verify schema of delete conversation
     # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

      # delete conversation
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    * match conDelete.response == {}

  Scenario: verify user is not able to delete conversation with invalid conversation id
     # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

      # delete conversation with invalid id
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(dummyId), status : 404}
    # validating error response
    * match conDelete.response == read(conversationResponses + 'conversationNotFound.json')

      # delete conversation
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 200}

  Scenario: verify user is not able to delete conversations that have expired its TTL time
    # creating a conversation with 3 sec as ttl
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}

    # waiting for 3 seconds
    * commonUtil.sleep(3)

    # deleting created conversation
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 404}
    # validating error response
    * match conDelete.response == read(conversationResponses + 'conversationNotFound.json')

  Scenario:  verify user is able to delete conversations that have expired its initial TTL time if its ttl was extended before expiry
    # creating a conversation with 3 sec as ttl
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation') {ttl : 3}

    # updating the created conversation
    * call read(reusableFeatures + 'common.feature@updateConversation') {id : #(conOne.response.id)}

    # waiting for 3 seconds
    * commonUtil.sleep(3)

    # delete the created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is not able to delete a conversation that is deleted already
       # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

      # delete conversation
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

    # deleting created conversation
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id), status : 404}
    # validating error response
    * match conDelete.response == read(conversationResponses + 'conversationNotFound.json')