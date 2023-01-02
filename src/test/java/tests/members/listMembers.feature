Feature: test cases for list members API


  Scenario: verify invalid and valid jwt response for members list api
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id
    #'hitting list members api with invalid token'
    * call read(baseCalls + '@get') {path: #(pathValue) , newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting list members api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(pathValue) , newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify member list api when no members are available
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id)}

      # validating schema
    * match response == []

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify members list api when members are available
      # creating 2 members
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def userTwo = call read(reusableFeatures + 'common.feature@createUser')

    * def memberOne = call read(reusableFeatures + 'common.feature@createMemberToConversation') {conversationId : #(conOne.response.id) , userId : #(userOne.response.id)}
    * def memberTwo = call read(reusableFeatures + 'common.feature@createMemberToConversation') {conversationId : #(conOne.response.id) , userId : #(userTwo.response.id)}

    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id)}

    # validating schema
    * match response == read(memberSchemas + '2members.json')

      # deleting created members
    * call read(reusableFeatures + 'common.feature@deleteMember') {conversationId : #(conOne.response.id) ,memberId : #(memberOne.response.id)}
    * call read(reusableFeatures + 'common.feature@deleteMember') {conversationId : #(conOne.response.id) ,memberId : #(memberTwo.response.id)}

    # deleting created users
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userTwo.response.id)}

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}


  Scenario: verify user is able to fetch latest set of members when a new member is added / removed

    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')

    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id)}
    * match response == '#[0]'

    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMemberToConversation') {conversationId : #(conOne.response.id) , userId : #(userOne.response.id)}

    # verifying the created member is present
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id)}
    * match response == '#[1]'
    * match response[0].state == 'INVITED'

      # deleting created members
    * call read(reusableFeatures + 'common.feature@deleteMember') {conversationId : #(conOne.response.id), memberId : #(memberOne.response.id)}

    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id)}
    # verifying the deleted member is not present
    * match response == '#[1]'
    * match response[0].state == 'LEFT'

     # deleting created users
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify user is not able to get members of deleted conversations
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

      # 'hitting list members api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id), status : 404}
    * match response == read(conversationResponses + 'conversationNotFound.json')