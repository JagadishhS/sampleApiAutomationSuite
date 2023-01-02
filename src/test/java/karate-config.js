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

  config.responses = 'classpath:responses/';
  config.conversationResponses = 'classpath:responses/conversations/';
  config.userResponses = 'classpath:responses/users';

  config.schemas = 'classpath:schemas/';
  config.conversationSchemas = 'classpath:schemas/conversations/';
  config.userSchemas = 'classpath:schemas/users/';

  config.tests = 'classpath:tests/';

  config.auth = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2NzI1NjgwMjksImV4cCI6MTY3Mjc0MDgyOSwianRpIjoiSjhQMXlZT0dLUkxlIiwiYXBwbGljYXRpb25faWQiOiIyYmE4MTczZS0wMTk4LTRlN2YtOWNkNS0yMTc5ZDVjNjRkYzYifQ.Qvr2E52-_07dOXvwkLsUUHCpLKvXs2r1A8Ia_eDfPR1Ann5WixXjcYtvP58hDQgmH7ioYej9cWQ6pMMCpkMH8WuaISi5bmbiemYZXNZQETpsSRvNLb6G7PYIBhiGZID4cVNtNS52JtQpwYLTGureOzr56xbN-AsRpVsqEmIrAFaJsSquWfwwjFxfT24ID0hR089AdDyM-7AkGuCy9G2UBDmDLTZZzuMq5U4Dv38qZfXTtkT3tNX2ou77aEjRxi3i40nogA-nbfI44t0pW6t6wFz6-gF9WlMFcDXcbywnwSv5Olh_2hNCtkY2J2nPQc5Ng8Rrw3cguCQpKpmD-7RrUQ'

  return config;
}
