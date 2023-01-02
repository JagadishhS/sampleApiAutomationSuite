Feature: test cases to get member by ID API

  Scenario: verify invalid and valid jwt response for get member by id api
    # creating a conversation
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = memberOne.returnData.conversationId
    * replace pathValue.member_id = memberOne.returnData.memberId
    #'hitting get members by id api with invalid token'
    * call read(baseCalls + '@get') {path: #(pathValue) , newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting list members api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(pathValue) , newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData

  Scenario: verify user is able to get deleted member
    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMember') memberOne.returnData

      # 'hitting get member by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@getMember') memberOne.returnData

    * match response.state == 'LEFT'

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id: #(memberOne.returnData.userId)}

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id: #(memberOne.returnData.conversationId)}

  Scenario: verify user not able to get member if member id is invalid
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conOne.response.id
    * replace pathValue.member_id = 'dummyMemberId'
    * call read(baseCalls + '@get') {path: #(pathValue), status : 404}

    * match response ==  read(memberResponses + 'memberNotFound.json')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id: #(conOne.response.id), status : 200}

  Scenario: validate json schema for get member by id api
      # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    # get the created member
    * call read(reusableFeatures + 'common.feature@getMember') memberOne.returnData
    * match response == read(memberSchemas + 'getMemberById.json')

    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData


