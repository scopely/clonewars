path = Npm.require 'path'
filesize = Meteor.npmRequire 'filesize'

Meteor.publish 'file-list', ->
  {user} = Meteor.users.findOne _id: @userId
  s3 = new AWS.S3()
  listObjectsSync = Meteor.wrapAsync s3.listObjects, s3
  files = listObjectsSync
    Bucket: Meteor.settings.public.bucket
    Prefix: "#{user}/"
  files = _.filter files.Contents, ({Key}) -> Key != user + '/'
  files = _.map files, ({Key, Size, LastModified}) =>
    Key: path.basename(Key)
    Size: filesize(Size)
    LastModified: LastModified
    userId: @userId
  FileList.remove userId: @userId
  for i, file of files
    FileList.insert file
  FileList.find userId: @userId,
    fields:
      Key: 1
      Size: 1
      LastModified: 1

AWS.config.update
  accessKeyId: Meteor.settings.AWSAccessKeyId
  secretAccessKey: Meteor.settings.AWSSecretAccessKey

Slingshot.createDirective 'files', Slingshot.S3Storage,
  bucket: Meteor.settings.public.bucket
  allowedFileTypes: /.*/
  maxSize: 0
  authorize: ->
    if not @userId
      throw new Meteor.Error("Login required!")
    else
      true
  key: (file) ->
    "#{Meteor.user().user}/#{file.name}"

Meteor.methods
  deleteFile: (file) ->
    user = Meteor.user().user
    s3 = new AWS.S3()
    deleteObjectSync = Meteor.wrapAsync s3.deleteObject, s3
    FileList.remove userId: Meteor.userId, Key: file.Key
    deleteObjectSync
      Key: "#{user}/#{file.Key}"
      Bucket: Meteor.settings.public.bucket

  getCredSpec: () ->
    sts = new AWS.STS()
    assumeRole = Meteor.wrapAsync sts.assumeRole, sts
    creds = assumeRole
      RoleArn: Meteor.settings.AWSReadRoleArn
      RoleSessionName: 'temporary-credentials'
    accessKey = creds.Credentials.AccessKeyId
    secretKey = creds.Credentials.SecretAccessKey
    "aws_access_key_id=#{accessKey};aws_secret_access_key=#{secretKey}"
