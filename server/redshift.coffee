connectSync = Meteor.wrapAsync pg.connect, pg

Meteor.methods
  checkAuth: (user, pass) ->
    url = Meteor.settings.Redshift.url
    connectionString = "postgres://#{user}:#{pass}@#{url}"
    try
      connectSync connectionString
      @setUserId user
      true
    catch e
      false
