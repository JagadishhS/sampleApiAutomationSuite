Feature: test cases to get event by ID API

  Scenario: verify invalid and valid jwt response for get event by id api
    # creating a conversation
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = eventOne.context.conversationId
    * replace pathValue.event_id = eventOne.context.eventId
    #'hitting get events by id api with invalid token'
    * call read(baseCalls + '@get') {path: #(pathValue), newAuth : 'dummyAuth', status : 401}

      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')
    # 'hitting list events api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(pathValue), newAuth : #(auth), status : 200}
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') eventOne.context

  Scenario: verify user is able to get deleted event
    # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    # deleting created event
    * call read(reusableFeatures + 'common.feature@deleteEvent') eventOne.context

      # 'hitting get event by id api with valid token and verifying status code'
    * def deletedEvent = call read(reusableFeatures + 'common.feature@getEvent') eventOne.context
    * match deletedEvent.response.body.timestamp.deleted == '#string'

    # deleting created entities
    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') eventOne.context

  Scenario: verify user not able to get event if event id is invalid
     # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = eventOne.context.conversationId
    * replace pathValue.event_id = -1

      #'hitting get events by id api with invalid token'
    * call read(baseCalls + '@get') {path: #(pathValue), status : 404}

    * match response ==  read(eventResponses + 'eventNotFound.json')

    * eventOne.context.status = 200
    # deleting created conversation
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') eventOne.context

  Scenario: validate json schema for get event by id api
      # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    # get the created event
    * call read(reusableFeatures + 'common.feature@getEvent') eventOne.context
    * match response == read(eventSchemas + 'getEventById.json')

    # deleting created event
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') eventOne.context


