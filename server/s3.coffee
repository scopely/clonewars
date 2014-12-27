path = Npm.require 'path'
filesize = Meteor.npmRequire 'filesize'

if Meteor.settings.AWS
  S3.config =
    key: Meteor.settings.AWS.accessKeyId
    secret: Meteor.settings.AWS.secretAccessKey
    bucket: Meteor.settings.AWS.bucket
else
  console.warn "AWS settings missing"

Meteor.publish 'file-list', (user) ->
  FileList.find user: user

Meteor.methods
  listFiles: (user) ->
    listObjectsSync = Meteor.wrapAsync S3.knox.list, S3.knox
    files = listObjectsSync
      prefix: "#{user}/"
    files = _.filter files.Contents, ({Key}) -> Key != user + '/'
    files = _.map files, ({Key, Size}) ->
      Key: path.basename(Key)
      Size: filesize(Size)
      user: user
    FileList.remove user: user
    for i, file of files
      FileList.insert file

  addFile: (s3Path, name, size, user) ->
    deleteFile = Meteor.wrapAsync S3.knox.deleteFile, S3.knox
    copyFile = Meteor.wrapAsync S3.knox.copyFile, S3.knox
    copyFile s3Path, "/#{user}/#{name}", (err, result) ->
      if err
        console.log err
      else
        deleteFile s3Path
        FileList.upsert Key: name,
          {
            $set:
              Key: name
              Size: filesize size
              user: user
          }


  deleteFile: (file, user) ->
    deleteObjectSync = Meteor.wrapAsync S3.knox.deleteFile, S3.knox
    deleteObjectSync "/#{user}/#{file.Key}"
    FileList.remove user: user, Key: file.Key
