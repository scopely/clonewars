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
          Meteor.call 'listFiles', user
      else
        FlashMessages.sendError('Login failed!')
    false

Template.body.helpers
  loggedIn: ->
    if Session.get('loggedIn')
      Tracker.autorun ->
        Meteor.subscribe 'file-list', Session.get('username')

Template.body.events
  'click #logout': (e) ->
    e.preventDefault()
    Session.set 'username', null
    Session.set 'password', null
    Tracker.autorun ->
      Session.set 'loggedIn', false

Template.fileList.helpers
  'files': -> FileList.find()

handleFiles = (event) ->
  user = Session.get 'username'
  files = event.target.files
  Session.set 'uploadingFile', files[0].name
  S3.upload files, "/#{user}", (err, result) ->
    if err
      FlashMessages.sendError "An error occurred! #{err.message}"

Template.fileList.events
  'dropped #dropzone': handleFiles

  'click #dropzone': (event) ->
    event.preventDefault()
    $('#dropzoneFile').trigger('click')

  'change #dropzoneFile': handleFiles

  'click .file': (event) ->
    event.preventDefault()
    Session.set 'currentFile', @
    $('#currentFile').modal()

Template.currentFile.helpers
  currentFile: -> Session.get 'currentFile'

Template.currentFile.events
  'click #delete': (event) ->
    Meteor.call 'deleteFile', @, Session.get('username'), (err, result) ->
      $('#currentFile').modal('hide')
      if err
        msg = err.message
        FlashMessages.sendError "There was an error deleting the file! #{msg}"

Template.uploadingFile.helpers
  uploading: ->
    file = S3.collection.findOne()
    if file?
      uploadingFile = Session.get 'uploadingFile'
      if file.percent_uploaded < 100
        file.name = uploadingFile
        file
      else
        unless file.uploading
          user = Session.get 'username'
          Meteor.call 'addFile',
            file._id, uploadingFile, file.total_uploaded, user
