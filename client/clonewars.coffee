Template.login.events
  'submit form': (e) ->
    e.preventDefault()
    user = e.target.username.value
    pass = e.target.password.value
    Meteor.call 'checkAuth', user, pass, (err, result) ->
      if result
        Tracker.autorun ->
          Session.set 'loggedIn', true
      else
        FlashMessages.sendError('Login failed!')
    false

Template.body.helpers
  loggedIn: -> Session.get 'loggedIn'

Template.body.events
  'click #logout': (e) ->
    e.preventDefault()
    Session.set 'username', null
    Session.set 'password', null
    Tracker.autorun ->
      Session.set 'loggedIn', false
