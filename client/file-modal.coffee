buildCopyCommand = (data, s3Path) ->
  base = ''
  if delimiter = data.delimiter
    base += """\nCSV
               DELIMITER '#{delimiter}'"""
  if compression = data.compression
    base += "\n#{compression}"
  if fixedwidth = data.fixedwidth
    base += "\n'#{fixedwidth}'"
  if json = data.json
    base += "\nJSON '#{json}'"
  if quote = data.quote
    base += "\nQUOTE '#{quote}'"
  if dateformat = data.dateformat
    base += "\nDATEFORMAT '#{dateformat}'"
  if timeformat = data.timeformat
    base += "\nTIMEFORMAT '#{timeformat}'"
  if ignoreheader = data.ignoreheader
    base += "\nIGNOREHEADER #{ignoreheader}"
  if maxerror = data.maxerror
    base += "\nMAXERROR #{maxerror}"
  if nullStr = data.null
    base += "\nNULL AS '#{nullStr}'"
  if fixedwidth = data.fixedwidth
    base += "\nFIXEDWIDTH '#{fixedwidth}'"
  if region = data.region
    base += "\nREGION '#{region}'"
  if manifest = data.manifest
    base += "\nMANIFEST '#{manifest}'"
  if comprows = data.comprows
    base += "\nCOMPROWS #{comprows}"
  if acceptinvchars = data.acceptinvchars
    base += "\nACCEPTINVCHARS '#{acceptinvchars}'"
  if (encoding = data.encoding) and encoding != "UTF8"
    base += "\nENCODING #{encoding}"

  base += "\nESCAPE" if escape = data.escape
  base += "\nEMPTYASNULL" if data.emptyasnull
  base += "\nBLANKSASNULL" if data.blanksasnull
  base += "\nENCRYPTED" if data.encrypted
  base += "\nIGNOREBLANKLINES" if data.ignoreblanklines
  base += "\nTRUNCATECOLUMNS" if data.truncatecolumns
  base += "\nTRIMBLANKS" if data.trimblanks
  base += "\nCOMPUPDATE OFF" if not data.compupdate
  base += "\nSTATUPDATE ON" if data.statupdate
  base += "\nSSH" if data.ssh
  base += "\nREMOVEQUOTES" if data.removequotes
  base += "\nEXPLICIT_IDS" if data.explicitids
  base += "\nFILLRECORD" if data.fillrecord
  base += "\nNOLOAD" if data.noload
  base += "\nROUNDEC" if data.roundec
  Session.set 'copyCommand',
    table: data.table or '...'
    options: base
    s3Path: s3Path

controlType = (element) ->
  if element.nodeName == "SELECT"
    "select"
  else
    element.getAttribute 'type'

getCreds = (cb) ->
  unless Session.get 'creds'
    Meteor.call 'getCredSpec', (err, creds) ->
      if err
        FlashMessages.sendError "Could not gen creds for you! #{err.message}"
      else
        Session.set 'creds', creds

handleCopyChange = (event) ->
  data = $('#copyForm .copy-control').toArray().reduce ((acc, input) ->
    id = input.getAttribute 'id'
    switch controlType input
      when 'text' then acc[id] = input.value
      when 'select' then acc[id] = $(input).val()
      when 'checkbox' then acc[id] = $(input).is ':checked'
    acc),
    {}
  bucket = Meteor.settings.public.bucket
  s3Path = "s3://#{bucket}/#{@user}/#{@Key}"
  buildCopyCommand(data, s3Path)
  false

Template.copyBox.helpers
  copyCommand: -> Session.get 'copyCommand'
  creds: -> Session.get 'creds'

Template.currentFile.helpers
  currentFile: -> Session.get 'currentFile'

Template.currentFile.events
  'click #delete': (event) ->
    Meteor.call 'deleteFile', @, Meteor.user().user, (err, result) ->
      $('#currentFile').modal 'hide'
      if err
        msg = err.message
        FlashMessages.sendError "There was an error deleting the file! #{msg}"

  'keyup #copyForm input[type="text"]': handleCopyChange
  'change #copyForm select': handleCopyChange
  'change #copyForm input[type="checkbox"]': handleCopyChange

Template.currentFile.rendered = ->
  @$('#currentFile').on 'hidden.bs.modal', (event) ->
    Session.set 'creds', null
    Session.set 'copyCommand', null
    Session.set 'currentFile', null
  @$('#currentFile').on 'shown.bs.modal', (event) ->
    getCreds()
