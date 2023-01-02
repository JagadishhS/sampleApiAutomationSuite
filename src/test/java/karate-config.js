function fn() {
  var env = karate.env; // get system property 'karate.env'
  var cUrl = karate.properties['url']
  if (!env) {
    env = 'prod';
  }

  var config = {
    env: env,
    commonUtil: Java.type('reusables.javautils.CommonUtil'),
    conversations : '/v0.1/conversations',
    conversationById : '/v0.1/conversations/<conversation_id>',
    recordConversationById : '/v1/conversations/<conversation_id>/record',
    users : '/v0.1/users',
    userById : '/v0.1/users/<user_id>',
    conversationsByUserId : '/v0.1/users/<user_id>/conversations',
    membersByConversationId : '/v0.1/conversations/<conversation_id>/members',
    memberByConversationIdAndMemberId : '/v0.1/conversations/<conversation_id>/members/<member_id>',
    eventsByConversationId : '/v0.1/conversations/<conversation_id>/events',
    eventByConversationIdAndEventId : '/v0.1/conversations/<conversation_id>/events/<event_id>',
    legs : '/v0.1/legs',
    legsById : '/v0.1/legs/<leg_id>'
  }

  if (cUrl != null) {
    config.baseUrl = cUrl
  } else if (env == 'staging') {
    config.baseUrl = ''
  } else if (env == 'prestaging') {
    config.baseUrl = ''
  } else if (env == 'prod') {
    config.baseUrl = 'https://api.nexmo.com/'
  } else if(env == 'test') {
    config.baseUrl = ''
  }

  config.reusables = 'classpath:reusables/';
  config.reusableFeatures = config.reusables + 'workflow/';
  config.baseCalls = config.reusableFeatures + 'baseCalls.feature';

  config.payloads = 'classpath:payloads/';
  config.conversationPayloads = 'classpath:payloads/conversations/';
  config.userPayloads = 'classpath:payloads/users/';
  config.memberPayloads = 'classpath:payloads/members/';
  config.eventPayloads = 'classpath:payloads/events/';

  config.responses = 'classpath:responses/';
  config.conversationResponses = 'classpath:responses/conversations/';
  config.userResponses = 'classpath:responses/users/';
  config.eventResponses = 'classpath:responses/events/';
  config.memberResponses = 'classpath:responses/members/';
  config.legResponses = 'classpath:responses/legs/';

  config.schemas = 'classpath:schemas/';
  config.conversationSchemas = 'classpath:schemas/conversations/';
  config.userSchemas = 'classpath:schemas/users/';
  config.eventSchemas = 'classpath:schemas/events/';
  config.memberSchemas = 'classpath:schemas/members/';
  config.legSchemas = 'classpath:schemas/legs/';

  config.tests = 'classpath:tests/';

  config.auth = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2NzI2ODE4OTcsImV4cCI6MTY3MzI4NjY5NywianRpIjoiYjI3MExCSWdOb25NIiwiYXBwbGljYXRpb25faWQiOiIyYmE4MTczZS0wMTk4LTRlN2YtOWNkNS0yMTc5ZDVjNjRkYzYifQ.OVsL-hE80icRElkXRCVuKzBd_JBS83kBkJhA5ECbjlrSuKzH2Sgj-rA7rwbuBKjtcU5GT43qopz4VRwOX-DMVoQsDbm7ILVfX_p1u-ftJsua8L8sVl667Rsaoe2HB_4rwJhok7NH7nfhIBuwxbMKrWiQVqeEJ-5foJ97cgi6VIdSOmkWGRImtFL3lPymmMIIt_VBR4cqj3KCQghBX8MSTM0r7hmhtNuN6LoXg-Z2tniUWfkjkILhLw6mF8QowPLXUlkGCZwYXZo_5_qoJdYj8INZrko7A29SztggKbW0AMaeQs-m-LFD31WGOC5ZZx3PhoVObJW03bysrWapvmaYyw'

  return config;
}
