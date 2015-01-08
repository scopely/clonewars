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
  if comprows = data.comprows
    base += "\nCOMPROWS #{comprows}"
  if acceptinvchars = data.acceptinvchars
    base += "\nACCEPTINVCHARS '#{acceptinvchars}'"
  if (encoding = data.encoding) and encoding != "UTF8"
    base += "\nENCODING #{encoding}"

  base += "\nMANIFEST" if data.manifest
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
  base += "\nEXPLICIT_IDS" if data.explicit_ids
  base += "\nFILLRECORD" if data.fillrecord
  base += "\nNOLOAD" if data.noload
  base += "\nROUNDEC" if data.roundec
  Session.set 'copyCommand',
    table: data['table-name'] or '...'
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
  currentFile = Session.get 'currentFile'
  bucket = Meteor.settings.public.bucket
  s3Path = "s3://#{bucket}/#{currentFile.user}/#{currentFile.Key}"
  buildCopyCommand(data, s3Path)
  false

Template.copyBox.helpers
  copyCommand: -> Session.get 'copyCommand'
  creds: -> Session.get 'creds'

Template.currentFile.helpers
  currentFile: -> Session.get 'currentFile'

  # Control descriptions in controls.coffee
  controls: -> controls

Template.popover.rendered = ->
  $('[data-toggle="popover"]').popover
    content: ->
      $(@).next().html()
    html: true

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
    $('#table-name').focus()
    $('[data-toggle="popover"]').popover 'hide'
    getCreds()
