path = Npm.require 'path'
filesize = Meteor.npmRequire 'filesize'

Meteor.publish 'file-list', (user) ->
  FileList.find user: user

AWS.config.update
  accessKeyId: Meteor.settings.AWSAccessKeyId
  secretAccessKey: Meteor.settings.AWSSecretAccessKey

Slingshot.createDirective 'files', Slingshot.S3Storage,
  bucket: Meteor.settings.bucket
  allowedFileTypes: /.*/
  maxSize: 0
  authorize: ->
    if not @userId
      throw new Meteor.Error("Login required!")
    else
      true
  key: (file) ->
    "#{@userId}/#{file.name}"

Meteor.methods
  listFiles: (user) ->
    s3 = new AWS.S3()
    listObjectsSync = Meteor.wrapAsync s3.listObjects, s3
    files = listObjectsSync
      Bucket: Meteor.settings.bucket
      Prefix: "#{user}/"
    files = _.filter files.Contents, ({Key}) -> Key != user + '/'
    files = _.map files, ({Key, Size}) ->
      Key: path.basename(Key)
      Size: filesize(Size)
      user: user
    FileList.remove user: user
    for i, file of files
      FileList.insert file

  deleteFile: (file, user) ->
    s3 = new AWS.S3()
    deleteObjectSync = Meteor.wrapAsync s3.deleteObject, s3
    deleteObjectSync
      Key: "#{user}/#{file.Key}"
      Bucket: Meteor.settings.bucket
    FileList.remove user: user, Key: file.Key
