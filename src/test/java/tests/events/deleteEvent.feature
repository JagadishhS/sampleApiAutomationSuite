Feature: test cases to delete event by ID API

  Scenario: verify invalid and valid jwt response for delete event by id api
     # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = eventOne.context.conversationId
    * replace pathValue.event_id = eventOne.context.eventId
    # 'hitting delete event by id api with invalid token'
    * call read(baseCalls + '@delete') {path: #(pathValue), newAuth : 'dummyAuth', status : 401}

      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    # 'hitting delete event by id api with valid token and verifying status code'
    * call read(baseCalls + '@delete') {path: #(pathValue), newAuth : #(auth), status : 200}
    # deleting all created entities
    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') eventOne.context

  Scenario: verify schema of delete event
     # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

      # delete event
    * def conDelete = call read(reusableFeatures + 'common.feature@deleteEvent') eventOne.context
    * match conDelete.response == {}

    * call read(reusableFeatures + 'common.feature@deleteBeyondEvent') eventOne.context

  Scenario: verify user is not able to delete event with invalid id
     # creating a event
    * def eventOne = call read(reusableFeatures + 'common.feature@createEvent')

    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = eventOne.context.conversationId
    * replace pathValue.event_id = -1
    * call read(baseCalls + '@delete') {path: #(pathValue), status:404}

      # 'verifying error response'
    * match response ==  read(eventResponses + 'eventNotFound.json')

    * eventOne.context.status = 200
      # delete user and conversation
    * call read(reusableFeatures + 'common.feature@deleteEventAndBeyond') eventOne.context