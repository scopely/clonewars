buildCopyCommand = (data, s3Path, creds) ->
  base = """COPY #{data.table}
            FROM #{s3Path}
            CREDENTIALS '#{creds}'"""
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
  base + ';'

controlType = (element) ->
  if element.nodeName == "SELECT"
    "select"
  else
    element.getAttribute 'type'

handleCopyChange = (event) ->
  data = $('#copyForm .copy-control').toArray().reduce ((acc, input) ->
    id = input.getAttribute 'id'
    switch controlType input
      when 'text' then acc[id] = input.value
      when 'select' then acc[id] = $(input).val()
      when 'checkbox' then acc[id] = $(input).is ':checked'
    acc),
    {}
  Meteor.call 'getCredSpec', (err, creds) =>
    Meteor.call 'getBucket', (err, bucket) =>
      s3Path = "s3://#{bucket}/#{@user}/#{@Key}"
      $('#copyText').val buildCopyCommand(data, s3Path, creds)
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

  'keyup #copyForm input[type="text"]': handleCopyChange
  'change #copyForm select': handleCopyChange
  'change #copyForm input[type="checkbox"]': handleCopyChange