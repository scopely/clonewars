Template.login.events
  'submit form': (e) ->
    e.preventDefault()
    user = e.target.username.value
    pass = e.target.password.value
    Meteor.loginWithPg user, pass, (err) ->
      unless err
        Tracker.autorun ->
          if user = Meteor.user()
            Meteor.call 'listFiles', user.user
      else
        FlashMessages.sendError("Login failed: #{err.message}")
    false

Template.body.helpers
  loggedIn: -> Meteor.user()

Template.body.events
  'click #logout': (e) ->
    e.preventDefault()
    Meteor.logout()
