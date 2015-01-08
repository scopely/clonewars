uploader = new Slingshot.Upload('files')

Template.fileList.helpers
  'files': -> FileList.find {}, sort: LastModified: -1
  'date': -> moment(@LastModified).fromNow()

handleFiles = (event) ->
  if event.type == "drop"
    files = event.originalEvent.dataTransfer.files
  else
    files = event.target.files
  file = files[0]
  Session.set 'uploadingFile', file.name
  uploader.send file, (err, url) ->
    if err
      console.log err
    else
      Meteor.call 'listFiles'

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
