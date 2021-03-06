# clonewars

The purpose of Clonewars is to provide an internal website/service you can run
to simplify the process of getting data from flat files into Redshift.

I wrote this, because the process for getting a non-technical person's data into
Redshift via a COPY command is as follows:

* Explain how COPY works and hope they read all of the documentation on options.
* Get them access to AWS S3.
* Teach them how to use S3.

Clonewars simplifies all three.

## Usage

Clonewars is written in CoffeeScript using [Meteor](http://meteor.com). Get
meteor by following the instructions on the website, then clone this repository.
In `settings.json`, put something like this:

```json
{
  "AWSAccessKeyId": "key",
  "AWSSecretAccessKey": "secret",
  "AWSReadRoleArn": "arn:aws:iam::account_id:role/CloneWarsReadAccess",

  "public": {
    "bucket": "clonewarsfiles"
  },

  "PG": {
    "url": "db.mydb.com/db"
  }
}
```

The key and secret you use should belong to an application-specific user that
only has S3 access to read and write to the bucket you specify here. The read
role is meant to be an IAM role that has read only access to the s3 bucket and
will be used to generate temporary credentials for COPY commands.

You can run the server for development like so:

```
$ meteor --settings settings.json
```

Then you can access the server at localhost:3000.

## How It Works

When you go to the website you'll find a login form asking for your Redshift
username and password. This is because Clonewars just checks that the user
authenticates with Redshift. This works because of [a postgres meteor accounts
adapter](https://github.com/Raynes/meteor-accounts-pg) that I wrote. Makes it
really easy to get your Redshift users in.

Users are allowed to upload files to S3 using the credentials you configured,
and each username gets its own directory in the bucket. The user gets a list of
files with their sizes.

Users can click on a file and they'll see a pop up. This is a COPY command
builder form. Each Redshift option (that makes sense) is covered, doc popovers
included, and the copy command is generated from your options. Next iteration
will regenerate the copy command for each change you make automatically.

The resulting COPY command will use credentials generated by assuming an IAM
role that ideally has read only access to the s3 files.

## Deploying

```
$ meteor build build
```

This will create a tarball in `build/clonewars.tar.gz`. It contains the entire
app bundled as a node app. On your server, extract it and do the following;

```
$ cd bundle/programs/server
$ npm install
$ cd ../..
$ cp path/to/settings.json .
$ METEOR_SETTINGS=$(cat settings.json) ROOT_URL=http://cw.mydomain.com PORT=3000 MONGO_URL=mongodb://localhost/ node main.js
```

You can set up an nginx reverse proxy to forward traffic to your node server:

```
map $http_upgrade $connection_upgrade {
  default upgrade;
  ''      close;
}

server {
  listen 80;
  server_name cw.scopely.cat;

  access_log            /var/log/nginx/cw.access.log;

  location / {
    proxy_set_header        Host $host;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_set_header        Upgrade $http_upgrade;
    proxy_set_header        Connection $connection_upgrade;
    proxy_http_version      1.1;
    proxy_pass          http://localhost:3000;
  }
}
```

Note the http upgrade stuff – that's all for websockets proxying and is
required.

I'd personally build an ansible playbook for the site and, since we're already
in AWS, why not a CloudFormation template for deploys? :D

## Security

The AWS access token you configure for Clonewars should be limited in scope to
reading and writing your S3 bucket. Furthermore, you should have an IAM role
that is limited to only reading from that bucket. This role will be used to
generate temporary credentials for generated copy commands that will expire in
an hour.

It should be possible to set things up in such a way that users only ever see
credentials that can access files in their own subdirectory of that bucket, but
the complexities involved in that don't seem worth it for a couple of reasons:

* Clonewars is designed to be deployed internally. You shouldn't expose it to
the world in the first place. Don't want folks trying to brute force logins
and spamming your PG/Redshift.
* The target audience is people who don't know what AWS credentials are, least
of all how to use them.
* There is kind of an assumption of trust that if your coworkers did manage to
see your files, there wouldn't really be anything there that they shouldn't see.

I'd accept a pull request facilitating the more complex scenario of limiting
folks to their own subdirectory in the bucket as long as it doesn't make things
terribly complicated.

## Screenshots

Here's a few screenshots to give you an idea of how it looks.

![](https://dl.dropboxusercontent.com/s/wi45mlnuobj3aqx/2015-01-07%20at%2011.46%20PM%202x.png?dl=0)
![](https://dl.dropboxusercontent.com/s/dp61vp1ityi2ci1/2015-01-08%20at%202.01%20PM.png?dl=0)

The doc popovers on each label:

![](https://dl.dropboxusercontent.com/s/ew5jw5pv846nqq2/2015-01-07%20at%2011.51%20PM%202x.png?dl=0)
