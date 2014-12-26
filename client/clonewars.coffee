Template.login.events
  'submit form': (e) ->
    e.preventDefault()
    user = e.target.username.value
    pass = e.target.password.value
    Meteor.call 'checkAuth', user, pass, (err, result) ->
      if result
        Tracker.autorun ->
          Session.set 'username', user
          Session.set 'loggedIn', true
          Meteor.call 'listFiles', user, (err, files) ->
            Session.set 'files', files
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

Template.fileList.helpers
  'files': -> Session.get 'files'

store = new FS.Store.S3 'files',
  folder: Session.get 'username'
Files = new FS.Collection 'files', stores: [store]

Template.fileList.events
  'dropped #dropzone': (event) ->
    FS.Utility.eachFile event, (file) ->
      Session.set 'uploading', file
      Files.insert file, (err, fileObj) ->
        if err
          FlashMessages.sendError("An error occurred! #{err.message}")
        else
          username = Session.get 'username'
          fileObj.name "#{username}/#{fileObj.name()}",
            store: store
          fileObj.on 'uploaded', ->
            Session.set 'uploading', null
            Meteor.call 'listFiles', username, (err, files) ->
              Session.set 'files', files

Template.uploadingFile.helpers
  uploading: -> Session.get 'uploading'
