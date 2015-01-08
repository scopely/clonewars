@controls =
  textFields: [
    {
      id: 'table-name'
      label: 'Table'
      popover: "Table name to copy into."
    }
    {
      id: 'delimiter'
      label: 'Delimiter'
      popover: "What columns are delimited by (e.g. \\t for tsv, , for csv)."
    }
    {
      id: 'json'
      label: 'JSON Paths'
      popover: "S3 path to a json paths file."
    }
    {
      id: 'quote'
      label: 'Quote Character'
      popover: "Set an alternative quote character (\" is the default)."
    }
    {
      id: 'dateformat'
      label: 'Date Format'
      popover: "Date format to use (YYYY-MM-DD is the default)."
    }
    {
      id: 'timeformat'
      label: 'Time Format'
      popover: "Time format to use (YYYY-MM-DD HH:MI:SS is the default)."
    }
    {
      id: 'ignoreheader'
      label: 'Ignore First Rows'
      popover: "Ignore the first N rows of the file (for headers and such)."
    }
  ]

  advancedTextFields: [
    {
      id: 'maxerror'
      label: 'Max Errors'
      popover: "Number of errors to tolerate before failure."
    }
    {
      id: 'null'
      label: 'Null Out'
      popover: "Sets columns matching this to null."
    }
    {
      id: 'fixedwidth'
      label: 'Fixed Width'
      popover: "Set specific column widths."
    }
    {
      id: 'region'
      label: 'Region'
      popover: "Explicitly set the AWS region to use."
    }
    {
      id: 'comprows'
      label: 'Comp Rows'
      popover: "Number of rows to use for compression analysis (default is 100000)."
    }
    {
      id: 'acceptinvchars'
      label: 'Accept Invalid'
      popover: "Accept invalid characters and replace them with this character."
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
      popover: "Compression of the file."
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
      popover: "Set the encoding of the file if it is expected to not be UTF-8."
    }
  ]

  leftCheckboxes: [
    {
      id: 'escape'
      label: 'Allow Escape'
      popover: "When enabled, \\ is treated as an escape character."
    }
    {
      id: 'emptyasnull'
      label: 'Null Empty Columns'
      popover: "If a column is empty, set it to null."
    }
    {
      id: 'blanksasnull'
      label: 'Null Blank Columns'
      popover: "If a column is a blank (whitespace-only), set it to null."
    }
    {
      id: 'encrypted'
      label: 'Encrypted'
      popover: "Check if the file has client side encryption."
    }
  ]

  rightCheckboxes: [
    {
      id: 'ignoreblanklines'
      label: 'Ignore Blank Lines'
      popover: "If there are empty whitespace lines, ignore them."
    }
    {
      id: 'truncatecolumns'
      label: 'Truncate Columns'
      popover: "If a varchar column is too short for a piece of data, truncate the data to fit."
    }
    {
      id: 'trimblanks'
      label: 'Trim Trailing Blanks'
      popover: "Trim trailing whitespace from columns."
    }
  ]

  advancedLeftCheckboxes: [
    {
      id: 'compupdate'
      label: 'Comp update'
      checked: true
      popover: "Perform compression analysis if the table is empty. Turn off if you don't care about compression."
    }
    {
      id: 'statupdate'
      label: 'Stat Update'
      popover: "Update optimizer statistics."
    }
    {
      id: 'ssh'
      label: 'SSH'
      popover: "If the file is a SSH manifest, check this."
    }
    {
      id: 'removequotes'
      label: 'Remove Quotes'
      popover: "Remove quotes from the data."
    }
    {
      id: 'manifest'
      label: 'Manifest'
      popover: "If set, treat file as a manifest file that specifies files to load."
    }
  ]

  advancedRightCheckboxes: [
    {
      id: 'explicit_ids'
      label: 'Explicit IDs'
      popover: "If your table has an automatic identity key, this explictly overrides that with ids in the file."
    }
    {
      id: 'fillrecord'
      label: 'Fill Record'
      popover: "Load data even if there are missing columns at the end, nulling them out."
    }
    {
      id: 'noload'
      label: "Don't Load"
      popover: "Don't actually load when executed, just test that it'll work."
    }
    {
      id: 'roundec'
      label: "Round Numerics"
      popover: "Round up numeric values when the value is of greater scale than the column definition."
    }
  ]
