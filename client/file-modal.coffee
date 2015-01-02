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


Template.currentFile.helpers
  currentFile: -> Session.get 'currentFile'

Template.currentFile.events
  'click #delete': (event) ->
    Meteor.call 'deleteFile', @, Meteor.user().user, (err, result) ->
      $('#currentFile').modal('hide')
      if err
        msg = err.message
        FlashMessages.sendError "There was an error deleting the file! #{msg}"

  'submit #copyForm': handleCopyChange
