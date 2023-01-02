Feature: test cases for update members API

  Scenario: verify invalid and valid jwt response for update members api
    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * args.newAuth = 'dummyAuth'
    * args.action = 'join'
    * args.status = 401
    # 'hitting update members api with invalid token'
    * call read(reusableFeatures + 'common.feature@updateMember') args
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    * args.status = 200
    * args.newAuth = auth
    # 'hitting update members api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateMember') {id : #(memberOne.response.id), newAuth : #(auth), status : 200}
    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData

  Scenario: verify user is able to update member by passing valid values in body
    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * args.action = 'join'
    * def memberOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getMember') args
    # 'hitting update members api with valid body and verifying status code'
    * call read(reusableFeatures + 'common.feature@updateMember') args
    * def memberOneAfterUpdate = call read(reusableFeatures + 'common.feature@getMember') args

    * match memberOneBeforeUpdate.response.member_id == memberOneAfterUpdate.response.member_id
    * match memberOneBeforeUpdate.response.state != memberOneAfterUpdate.response.state

    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') args

  Scenario: verify user is not able to update member by passing invalid values in body
    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * args.action = 'JOIN'
    * def memberOneBeforeUpdate = call read(reusableFeatures + 'common.feature@getMember') args

    # 'hitting update members api with invalid body and verifying status code'
    * args.status =400
    * call read(reusableFeatures + 'common.feature@updateMember') args

     # validating error response
    * match response == read(memberResponses + 'updateMemberInvalidState.json')

    * args.status =200
    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') args

  Scenario: verify user is not able to update member by passing invalid member id in path param
    # 'hitting update members api with invalid body and verifying status code'
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * def memId = memberOne.returnData.memberId
    * args.memberId = 'dummyId'
    * args.status = 404
    * args.action = 'join'
    * call read(reusableFeatures + 'common.feature@updateMember') args

     # validating error response
    * match response == read(memberResponses + 'memberNotFound.json')

    * args.memberId = memId
    * args.status = 200
    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData


  Scenario: verify member is not able to update deleted member
      # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    # verifying the created member is present
    * call read(reusableFeatures + 'common.feature@getMembers') memberOne.returnData
    * match response == '#[1]'

    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMember') memberOne.returnData

    * def args = memberOne.returnData
    * args.action = 'join'
    * args.status = 400
    * call read(reusableFeatures + 'common.feature@updateMember') args
    # validating error response
    * match response == read(memberResponses + 'updateDeletedMember.json')

    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(args.conversationId), status : 200}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(args.userId), status : 200}

  Scenario: verify the response schema after update
    # creating a member
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    # verifying the created member is present
    * call read(reusableFeatures + 'common.feature@getMembers') memberOne.returnData
    * match response == '#[1]'

    * def args = memberOne.returnData
    * args.action = 'join'
    * def memberUpdate = call read(reusableFeatures + 'common.feature@updateMember') args
    # validating response Schema
    * match memberUpdate.response == read(memberSchemas + 'updateMember.json')

    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') args