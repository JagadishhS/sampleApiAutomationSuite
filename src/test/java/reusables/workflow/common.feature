Feature: reusable calls for common APIs

  @createConversation
  Scenario: create conversation
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * body.name = commonUtil.random('name')
    * body.display_name = commonUtil.random('name')
    * body.properties.ttl = typeof ttl == 'undefined' ? 10 : ttl
    * call read(baseCalls + '@post') {path: #(conversations), content : #(body)}

  @deleteConversation
  Scenario: delete conversation
    * def value = conversationById
    * replace value.conversation_id = id
    * call read(baseCalls + '@delete') {path: #(value) }

  @updateConversation
  Scenario: create conversation
    * def value = conversationById
    * replace value.conversation_id = id
    * def body = read(conversationPayloads + 'createConversationAllValid.json')
    * body.name = commonUtil.random('name')
    * body.display_name = commonUtil.random('name')
    * body.properties.ttl = typeof ttl == 'undefined' ? 20 : ttl
    * call read(baseCalls + '@put') {path: #(value), content : #(body)}

  @getConversation
  Scenario: get conversation
    * def value = conversationById
    * replace value.conversation_id = id
    * call read(baseCalls + '@get') {path: #(value) }

  @getConversations
  Scenario: getConversations
    * call read(baseCalls + '@get') {path : #(conversations)}

  @createUser
  Scenario: create user
    * def body = read(userPayloads + 'createUserAllValid.json')
    * body.name = commonUtil.random('name')
    * body.display_name = commonUtil.random('name')
    * call read(baseCalls + '@post') {path: #(users), content : #(body)}

  @deleteUser
  Scenario: delete user
    * def value = userById
    * replace value.user_id = id
    * call read(baseCalls + '@delete') {path: #(value) }

  @getUsers
  Scenario: getUsers
    * call read(baseCalls + '@get') {path : #(users)}

  @getUser
  Scenario: get user
    * def value = userById
    * replace value.user_id = id
    * call read(baseCalls + '@get') {path: #(value) }

  @updateUser
  Scenario: create conversation
    * def value = userById
    * replace value.user_id = id
    * def body = read(userPayloads + 'createUserAllValid.json')
    * body.name = commonUtil.random('name')
    * body.display_name = commonUtil.random('name')
    * call read(baseCalls + '@put') {path: #(value), content : #(body)}

  @createMember
  Scenario: create member
    * def conOne = call read(reusableFeatures + 'common.feature@createConversation')
    * def userOne = call read(reusableFeatures + 'common.feature@createUser')
    * def body = read(memberPayloads + 'createMemberAllValid.json')
    * body.user_id = userOne.response.id
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conOne.response.id
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}
    * def returnData = {conversationId : #(conOne.response.id), memberId : #(response.id), userId : #(userOne.response.id)}

  @updateMember
  Scenario: update member
    * def body = read(memberPayloads + 'createMemberAllValid.json')
    * body.user_id = userId
    * body.action = action
    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.member_id = memberId
    * call read(baseCalls + '@put') {path: #(pathValue), content : #(body)}
    * def returnData = {conversationId : #(conOne.response.id), memberId : #(response.id), userId : #(userOne.response.id)}

  @createMemberToConversation
  Scenario: create member to conversation
    * def body = read(memberPayloads + 'createMemberAllValid.json')
    * body.user_id = userId
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conversationId
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}

  @deleteMember
  Scenario: delete member
    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.member_id = memberId
    * call read(baseCalls + '@delete') {path: #(pathValue)}

  @deleteMemberAndBeyond
  Scenario: delete member and beyond
    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.member_id = memberId
    * call read(baseCalls + '@delete') {path: #(pathValue)}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id: #(conversationId)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id: #(userId)}


  @getMember
  Scenario: get member
    * def pathValue = memberByConversationIdAndMemberId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.member_id = memberId
    * call read(baseCalls + '@get') {path: #(pathValue)}

  @getMembers
  Scenario: get members
    * def pathValue = membersByConversationId
    * replace pathValue.conversation_id = conversationId
    * call read(baseCalls + '@get') {path: #(pathValue)}

  @getEvents
  Scenario: get events
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = conversationId
    * call read(baseCalls + '@get') {path: #(pathValue)}

  @getEvent
  Scenario: get event
    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.event_id = eventId
    * call read(baseCalls + '@get') {path: #(pathValue)}

  @createEvent
  Scenario: create event
    * def memOne = call read(reusableFeatures + 'common.feature@createMember')
    * def userTwo = call read(reusableFeatures + 'common.feature@createUser')
    * def memTwo = call read(reusableFeatures + 'common.feature@createMemberToConversation') {conversationId : #(memOne.returnData.conversationId), userId: #(userTwo.response.id)}

    * call read(reusableFeatures + 'common.feature@updateMember') {conversationId : #(memOne.returnData.conversationId), userId: #(userTwo.response.id), memberId : #(memTwo.response.id), action : 'join'}
    * call read(reusableFeatures + 'common.feature@updateMember') {conversationId : #(memOne.returnData.conversationId), userId: #(memOne.returnData.userId), memberId : #(memOne.returnData.memberId), action : 'join'}

    * def body = read(eventPayloads + 'createEventAllValid.json')
    * body.to = memTwo.response.id
    * body.from = memOne.returnData.memberId
    * def pathValue = eventsByConversationId
    * replace pathValue.conversation_id = memOne.returnData.conversationId
    * call read(baseCalls + '@post') {path: #(pathValue), content : #(body)}
    * def context = {}
    * context.conversationId = memOne.returnData.conversationId
    * context.eventId = response.id
    * context.memberOneId = memOne.returnData.memberId
    * context.memberTwoId = memTwo.response.id
    * context.userOneId = memOne.returnData.userId
    * context.userTwoId = userTwo.response.id

  @deleteEvent
  Scenario: delete event
    * def pathValue = eventByConversationIdAndEventId
    * replace pathValue.conversation_id = conversationId
    * replace pathValue.event_id = eventId
    * call read(baseCalls + '@delete') {path: #(pathValue)}


  @deleteEventAndBeyond
  Scenario: delete event and all related entities
    * call read(reusableFeatures + 'common.feature@deleteEvent') {conversationId : #(conversationId), eventId : #(eventId)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOneId)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userTwoId)}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conversationId)}

  @deleteBeyondEvent
  Scenario: delete all related prep data
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userOneId)}
    * call read(reusableFeatures + 'common.feature@deleteUser') {id : #(userTwoId)}
    * call read(reusableFeatures + 'common.feature@deleteConversation') {id : #(conversationId)}

  @prepareCreateEvent
  Scenario: prepare create event
    * def memOne = call read(reusableFeatures + 'common.feature@createMember')
    * def userTwo = call read(reusableFeatures + 'common.feature@createUser')
    * def memTwo = call read(reusableFeatures + 'common.feature@createMemberToConversation') {conversationId : #(memOne.returnData.conversationId), userId: #(userTwo.response.id)}

    * call read(reusableFeatures + 'common.feature@updateMember') {conversationId : #(memOne.returnData.conversationId), userId: #(userTwo.response.id), memberId : #(memTwo.response.id), action : 'join'}
    * call read(reusableFeatures + 'common.feature@updateMember') {conversationId : #(memOne.returnData.conversationId), userId: #(memOne.returnData.userId), memberId : #(memOne.returnData.memberId), action : 'join'}

    * def context = {}
    * context.conversationId = memOne.returnData.conversationId
    * context.memberOneId = memOne.returnData.memberId
    * context.memberTwoId = memTwo.response.id
    * context.userOneId = memOne.returnData.userId
    * context.userTwoId = userTwo.response.id