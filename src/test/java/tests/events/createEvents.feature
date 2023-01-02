Feature: test cases for create events API

  Scenario: verify invalid and valid jwt response for create events api
    * def prep = call read(reusableFeatures + 'common.feature@prepareCreateEvent')

    * def body = read(eventPayloads + 'createEventAllValid.json')
    * body.to = prep.context.memberOneId
    * body.from =  prep.context.memberTwoId
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = prep.context.conversationId

    # 'hitting create events api with invalid token'
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body), newAuth : 'dummyAuth', status : 401}

      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    # 'hitting create events api with valid token and verifying status code'
    * def eventOne = call read(baseCalls + '@post') {path: #(pathValue), content : #(body), newAuth : #(auth), status : 200}
    * def args = prep.context
    * args.eventId = eventOne.response.id
    * args.newAuth = auth
    * args.status = 200
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') args


  Scenario: verify schema of create events with all valid inputs in body
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')
    * match eventOne.response == read(eventSchemas + 'createEvents.json')
    
    # deleting created event
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') eventOne.context

  Scenario: verify schema of create events with all invalid inputs in body
    * def prep = call read(reusableFeatures + 'common.feature@prepareCreateEvent')

    * def body = read(eventPayloads + 'createEventAllInValid.json')
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = prep.context.conversationId
    # 'hitting create events api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body), status : 400}

    # validating error response
    * match response == read(eventResponses + 'createEventAllInValid.json')

    # verify no events created
    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(prep.context.conversationId),status : 200}
    * match response == '#[4]'

    # deleting created data
    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') prep.context

  Scenario: verify user is able to create duplicate events
    * def prep = call read(reusableFeatures + 'common.feature@prepareCreateEvent')

    * def body = read(eventPayloads + 'createEventAllValid.json')
    * body.to = prep.context.memberOneId
    * body.from = prep.context.memberTwoId
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = prep.context.conversationId
    # creating event for first time
    * def eventOne = call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}
    # creating same event for second time
    * def eventTwo = call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}

     # verify 2 events created
    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(prep.context.conversationId)}
    * match response == '#[6]'

    * call read(reusableFeatures + 'common.feature@deleteEvent') {conversationId : #(prep.context.conversationId), eventId : #(eventOne.response.id)}
    * call read(reusableFeatures + 'common.feature@deleteEvent') {conversationId : #(prep.context.conversationId), eventId : #(eventTwo.response.id)}

    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') prep.context

  Scenario: verify user is not able to create event with empty body
    * def prep = call read(reusableFeatures + 'common.feature@prepareCreateEvent')

    * def body = {}
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = prep.context.conversationId

    # 'hitting create events api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body) , status : 400}

    # validating error response
    * match response == read(eventResponses + 'createEventEmptyBody.json')

    # verify no events created
    * call read(reusableFeatures + 'common.feature@getEvents') {conversationId : #(prep.context.conversationId),status : 200}
    * match response == '#[4]'

    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') prep.context

  Scenario: verify user is not able to create event with invalid conversation id
    * def prep = call read(reusableFeatures + 'common.feature@prepareCreateEvent')

    * def body = read(eventPayloads + 'createEventAllValid.json')
    * body.to = prep.context.memberOneId
    * body.from = prep.context.memberTwoId
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = 'dummyId'
    # 'hitting create events api
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body),  status : 404}

    # validating error response
    * match response == read(conversationResponses + 'conversationNotFound.json')

    * prep.context.status = 200
    # deleting created user
    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') prep.context