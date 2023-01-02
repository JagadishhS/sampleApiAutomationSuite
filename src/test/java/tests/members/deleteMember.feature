Feature: test cases to delete member by ID API

  Scenario: verify invalid and valid jwt response for delete member by id api
     # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * args.newAuth = 'dummyAuth'
    * args.status = 401
    # 'hitting delete member by id api with invalid token'
    * call read(reusableFeatures + 'common.feature@deleteMember') args
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    * args.newAuth = auth
    * args.status = 200
    # 'hitting delete member by id api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') args

  Scenario: verify schema of delete member
     # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

      # delete member
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteMember') memberOne.returnData
    * match conDelete.response == {}

    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(memberOne.returnData.userId)}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(memberOne.returnData.conversationId)}

  Scenario: verify user is not able to delete member that is already deleted
     # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

      # delete member with invalid id
    * call read(reusableFeatures + 'common.feature@deleteMember') memberOne.returnData
    * def args = memberOne.returnData
    * args.status = 400
    * call read(reusableFeatures + 'common.feature@deleteMember')  args

      # 'verifying error response'
    * match response ==  read(memberResponses + 'deleteDeletedMember.json')

      # delete user and conversation
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(memberOne.returnData.userId),status : 200}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(memberOne.returnData.conversationId)}

  Scenario: verify user not able to delete member if member id is invalid
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conOne.response.id
    * replace pathValue.member_id = 'dummyMemberId'
    * call read(baseCalls + '@delete') {path: #(pathValue), status : 404}

    * match response ==  read(memberResponses + 'memberNotFound.json')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id: #(conOne.response.id), status : 200}