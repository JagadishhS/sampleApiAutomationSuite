Feature: test cases for list events API


  Scenario: verify invalid and valid jwt response for events list api
    # creating a conversation
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    #'hitting list events api with invalid token'
    * def args = memberOne.returnData
    * args.newAuth = 'dummyAuth'
    * args.status = 401
    * call read(reusableFeatures + 'common.feature@getEvents') args
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    # 'hitting list events api with valid token and verifying status code'
    * args.newAuth = auth
    * args.status = 200
    * call read(reusableFeatures + 'common.feature@getEvents') args

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') args

  Scenario: verify event list api when no events are available
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(conOne.response.id)}

      # validating schema
    * match response == []

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

  Scenario: verify events list api when events are available
      # creating 2 events
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')
    * def args = memberOne.returnData
    * args.action = 'join'
    * call read(reusableFeatures + 'common.feature@updateMember') args

    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(memberOne.returnData.conversationId)}

    # validating schema
    * match response == read(eventSchemas + '2events.json')

      # deleting created events
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData


  Scenario: verify user is able to fetch latest set of events when a new event is added / removed

    # creating 2 events
    * def memberOne = call read(reusableFeatures + 'common.feature@createMember')

    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(memberOne.returnData.conversationId)}
    * match response == '#[1]'

    * def args = memberOne.returnData
    * args.action = 'join'
    * call read(reusableFeatures + 'common.feature@updateMember') args

    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(memberOne.returnData.conversationId)}
    * match response == '#[2]'

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteMemberAndBeyond') memberOne.returnData

  Scenario: verify user is not able to get events of deleted conversations
    # creating a conversation
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')

    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conOne.response.id)}

      # 'hitting list events api with valid token and verifying status code'
    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(conOne.response.id), status : 404}
    * match response == read(conversationResponses + 'conversationNotFound.json')