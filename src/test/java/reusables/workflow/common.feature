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
  Scenario: delete conversation
    * def value = conversationById
    * replace value.conversation_id = id
    * call read(baseCalls + '@get') {path: #(value) }