uploader = new Slingshot.Upload('files')

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
    $('#currentFile').modal backdrop: false

Template.uploadingFile.helpers
  uploading: ->
    filename = Session.get 'uploadingFile'
    if filename and uploader.status() is 'transferring'
      name: filename
      percent_uploaded: Math.round(uploader.progress() * 100)
