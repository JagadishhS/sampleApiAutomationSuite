Feature: test cases for list legs API

  Scenario: verify invalid and valid jwt response for legs list api
    #'hitting list legs api with invalid token'
    * call read(baseCalls + '@get') {path: #(legs), newAuth : 'dummyAuth', status : 401}
      # 'verifying error response'
    * match response ==  read(responses + 'invalidJWT.json')

    # 'hitting list legs api with valid token and verifying status code'
    * call read(baseCalls + '@get') {path: #(legs), newAuth : #(auth), status : 200}

  Scenario: verify leg list api when no legs are available
    * call read(baseCalls + '@get') {path: #(legs), newAuth : #(auth), status : 200}
      # validating schema
    * match response == read(legSchemas + 'noLegs.json')