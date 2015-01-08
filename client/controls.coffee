@controls =
  textFields: [
    {
      id: 'table'
      label: 'Table'
    }
    {
      id: 'delimiter'
      label: 'Delimiter'
    }
    {
      id: 'json'
      label: 'JSON Paths'
    }
    {
      id: 'quote'
      label: 'Quote Character'
    }
    {
      id: 'dateformat'
      label: 'Date Format'
    }
    {
      id: 'timeformat'
      label: 'Time Format'
    }
    {
      id: 'ignoreheader'
      label: 'Ignore First Rows'
    }
  ]

  advancedTextFields: [
    {
      id: 'maxerror'
      label: 'Max Errors'
    }
    {
      id: 'null'
      label: 'Null Out'
    }
    {
      id: 'fixedwidth'
      label: 'Fixed Width'
    }
    {
      id: 'region'
      label: 'Region'
    }
    {
      id: 'manifest'
      label: 'Manifest'
    }
    {
      id: 'comprows'
      label: 'Comp Rows'
    }
    {
      id: 'acceptinvchars'
      label: 'Accept Invalid'
    }
  ]

  advancedDropdowns: [
    {
      id: 'compression'
      label: 'Compression'
      options: [
        {
          value: ''
          text: 'None'
        }
        {
          value: 'GZIP'
          text: 'GZIP'
        }
        {
          value: 'LZOP'
          text: 'LZOP'
        }
      ]
    }
    {
      id: 'encoding'
      label: 'Encoding'
      options: [
        {
          value: 'UTF8'
          text: 'UTF-8'
        }
        {
          value: 'UTF16'
          text: 'UTF-16'
        }
        {
          value: 'UTF16LE'
          text: 'UTF-16LE'
        }
        {
          value: 'UTF16BE'
          text: 'UTF-16BE'
        }
      ]
    }
  ]

  leftCheckboxes: [
    {
      id: 'escape'
      label: 'Allow Escape'
    }
    {
      id: 'emptyasnull'
      label: 'Null Empty Columns'
    }
    {
      id: 'blanksasnull'
      label: 'Null Blank Columns'
    }
    {
      id: 'encrypted'
      label: 'Encrypted'
    }
  ]

  rightCheckboxes: [
    {
      id: 'ignoreblanklines'
      label: 'Ignore Blank Lines'
    }
    {
      id: 'truncatecolumns'
      label: 'Truncate Columns'
    }
    {
      id: 'trimblanks'
      label: 'Trim Trailing Blanks'
    }
  ]

  advancedLeftCheckboxes: [
    {
      id: 'compupdate'
      label: 'Comp update'
      checked: true
    }
    {
      id: 'statupdate'
      label: 'Status Update'
    }
    {
      id: 'ssh'
      label: 'SSH'
    }
    {
      id: 'removequotes'
      label: 'Remove Quotes'
    }
  ]

  advancedRightCheckboxes: [
    {
      id: 'explicit_ids'
      label: 'Explicit IDs'
    }
    {
      id: 'fillrecord'
      label: 'Fill Record'
    }
    {
      id: 'noload'
      label: "Don't Load"
    }
    {
      id: 'roundec'
      label: "Round Numerics"
    }
  ]
