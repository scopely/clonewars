connectSync = Meteor.wrapAsync(pg.connect, pg)

Meteor.methods
  checkAuth: (user, pass) ->
    connectionString = "postgres://#{user}:#{pass}@#{process.env.URL}"
    try
      connectSync connectionString
      true
    catch e
      false
