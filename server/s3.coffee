path = Npm.require 'path'
filesize = Meteor.npmRequire 'filesize'

if Meteor.settings.AWS
  AWS.config.update
    accessKeyId: Meteor.settings.AWS.accessKeyId
    secretAccessKey: Meteor.settings.AWS.secretAccessKey

    store = new FS.Store.S3 'files',
      region: Meteor.settings.AWS.region or 'us-east-1'
      accessKeyId: Meteor.settings.AWS.accessKeyId
      secretAccessKey: Meteor.settings.AWS.secretAccessKey
      bucket: Meteor.settings.AWS.bucket
      fileKeyMaker: (file) ->
        file.name()
    Files = new FS.Collection 'files', stores: [store]
else
  console.warn "AWS settings missing"

Meteor.methods
  listFiles: (user) ->
    s3 = new AWS.S3()
    listObjectsSync = Meteor.wrapAsync s3.listObjects, s3
    files = listObjectsSync
      Bucket: Meteor.settings.AWS.bucket
      Prefix: "#{user}/"
    files = _.filter files.Contents, ({Key}) -> Key != user + '/'
    _.map files, ({Key, Size}) ->
      Key: path.basename(Key)
      Size: filesize(Size)
      bucket: Meteor.settings.AWS.bucket
