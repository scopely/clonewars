uploader = new Slingshot.Upload('files')

Template.login.events
  'submit form': (e) ->
    e.preventDefault()
    user = e.target.username.value
    pass = e.target.password.value
    Meteor.loginWithPg user, pass, (err) ->
      unless err
        Tracker.autorun ->
          Meteor.call 'listFiles', Meteor.user().user
      else
        FlashMessages.sendError("Login failed: #{err.message}")
    false

Template.body.helpers
  loggedIn: ->
    if Meteor.user()
      Tracker.autorun ->
        Meteor.subscribe 'file-list', Meteor.user().user

Template.body.events
  'click #logout': (e) ->
    e.preventDefault()
    Meteor.logout()

Template.fileList.helpers
  'files': -> FileList.find()

handleFiles = (event) ->
  user = Meteor.user().user
  file = event.target.files[0]
  Session.set 'uploadingFile', file.name
  uploader.send file, (err, url) ->
    if err
      console.log err
    else
      Meteor.call 'listFiles', user

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

buildCopyCommand = (data, s3Path, creds) ->
  base = """COPY #{data.table}
            FROM #{s3Path}
            CREDENTIALS '#{creds}'"""
  if delimiter = data.delimiter
    base += "\nDELIMITER '#{delimiter}'\n"
  base

handleCopyChange = (event) ->
  data = $('#copyForm input').toArray().reduce ((acc, input) ->
    id = input.getAttribute 'id'
    switch input.getAttribute('type')
      when 'text' then acc[id] = input.value
    acc),
    {}
  Meteor.call 'getCredSpec', (err, creds) =>
    Meteor.call 'getBucket', (err, bucket) =>
      s3Path = "s3://#{bucket}/#{@user}/#{@Key}"
      $('#copyText').val buildCopyCommand(data, s3Path, creds)
      console.log data
  false

Template.currentFile.events
  'click #delete': (event) ->
    Meteor.call 'deleteFile', @, Meteor.user().user, (err, result) ->
      $('#currentFile').modal('hide')
      if err
        msg = err.message
        FlashMessages.sendError "There was an error deleting the file! #{msg}"

  'submit #copyForm': handleCopyChange

Template.uploadingFile.helpers
  uploading: ->
    filename = Session.get 'uploadingFile'
    if filename and uploader.status() is 'transferring'
      name: filename
      percent_uploaded: Math.round(uploader.progress() * 100)
