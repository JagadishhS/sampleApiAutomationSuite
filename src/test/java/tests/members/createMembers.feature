Feature: test cases for create members API

  Scenario: verify invalid and valid jwt response for create members api
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body = read(memberPayloads + 'createMemberAllValid.json')
    * body.user_id = userOne.response.id
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id

    # 'hitting create members api with invalid token'
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body), newAuth : 'dummyAuth', status : 401}

      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    # 'hitting create members api with valid token and verifying status code'
    * def memberOne = call read(baseCalls + '@post') {path: #(pathValue), content : #(body), newAuth : #(auth), status : 200}
    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMember') {conversationId : #(conOne.response.id), memberId : #(memberOne.response.id)}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify schema of create members with all valid inputs in body
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * match memberOne.response == read(memberSchemas + 'createMembers.json')
    
    # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData

  Scenario: verify schema of create members with all invalid inputs in body
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body = read(memberPayloads + 'createMemberAllInValid.json')
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id

    # 'hitting create members api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body),  status : 400}

    # validating error response
    * match response == read(memberResponses + 'createMemberAllInValid.json')

    # verify no members created
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id),status : 200}
    * match response == '#[0]'

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to create duplicate members
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body = read(memberPayloads + 'createMemberAllValid.json')
    * body.user_id = userOne.response.id
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id

    * def memberOne = call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body), status : 400}
    # validating error response
    * match response == read(memberResponses + 'duplicateMember.json')

    # verify duplicate member not created
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id),status : 200}
    * match response == '#[1]'

     # deleting created member
    * call read(reusableFeatures + 'common.feature@deleteMember') {conversationId : #(conOne.response.id), memberId : #(memberOne.response.id)}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to create member with empty body
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body = {}
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id

    # 'hitting create members api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body),  status : 400}

    # validating error response
    * match response == read(memberResponses + 'createMemberEmptyBody.json')

    # verify no members created
    * call read(reusableFeatures + 'common.feature@getMembers') {conversationId : #(conOne.response.id),status : 200}
    * match response == '#[0]'

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id)}

  Scenario: verify user is not able to create member with invalid conversation id
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body =  read(memberPayloads + 'createMemberAllValid.json')
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = 'dummyConversationId'

    # 'hitting create members api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body),  status : 404}

    # validating error response
    * match response == read(conversationResponses + 'conversationNotFound.json')

    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOne.response.id),status : 200}