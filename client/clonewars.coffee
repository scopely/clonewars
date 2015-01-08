Template.login.events
  'submit form': (e) ->
    e.preventDefault()
    user = e.target.username.value
    pass = e.target.password.value
    Meteor.loginWithPg user, pass, (err) ->
      FlashMessages.sendError("Login failed: #{err.message}") if err
    false

Template.login.rendered = -> $('#username').focus()

Template.body.helpers
  loggedIn: -> Meteor.user()

Template.body.events
  'click #logout': (e) ->
    e.preventDefault()
    Meteor.logout()
