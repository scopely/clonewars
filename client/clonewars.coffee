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

handleFiles = (event) ->
  FS.Utility.eachFile event, (file) ->
    Files.insert file, (err, fileObj) ->
      if err
        FlashMessages.sendError("An error occurred! #{err.message}")
      else
        Session.set 'uploading', fileObj
        username = Session.get 'username'
        fileObj.name "#{username}/#{fileObj.name()}",
          store: store
        fileObj.on 'uploaded', ->
          Meteor.call 'listFiles', username, (err, files) ->
            Session.set 'files', files

Template.fileList.events
  'dropped #dropzone': handleFiles

  'click #dropzone': (event) ->
    event.preventDefault()
    $('#dropzoneFile').trigger('click')

  'change #dropzoneFile': handleFiles

Template.uploadingFile.helpers
  uploading: ->
    file = Session.get 'uploading'
    if file?
      if file.isUploaded()
        Session.set 'uploading', null
      else
        console.log file.uploadProgress()
        file.progress = file.uploadProgress()
        file
