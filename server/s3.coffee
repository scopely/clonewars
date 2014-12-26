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

Meteor.publish 'fileList', (user) ->
  FileList.find user: user

Meteor.methods
  listFiles: (user) ->
    s3 = new AWS.S3()
    listObjectsSync = Meteor.wrapAsync s3.listObjects, s3
    files = listObjectsSync
      Bucket: Meteor.settings.AWS.bucket
      Prefix: "#{user}/"
    files = _.filter files.Contents, ({Key}) -> Key != user + '/'
    files = _.map files, ({Key, Size}) ->
      Key: path.basename(Key)
      Size: filesize(Size)
      user: user
      bucket: Meteor.settings.AWS.bucket
    FileList.remove user: user
    for i, file of files
      FileList.insert file

  deleteFile: (file, user) ->
    s3 = new AWS.S3()
    deleteObjectSync = Meteor.wrapAsync s3.deleteObject, s3
    deleteObjectSync
      Bucket: file.bucket
      Key: "#{user}/#{file.Key}"
    FileList.remove user: user, Key: file.Key
