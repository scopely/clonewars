# clonewars

The purpose of Clonewars is to provide an internal website/service you can run
to simplify the process of getting data from flat files into Redshift.

I wrote this, because the process for getting a non-technical person's data into
Redshift via a COPY command is as follows:

* Explain how COPY works and hope they read all of the documentation on options.
* Get them access to AWS S3.
* Teach them how to use S3.

That second and third bit is the part I'm trying to simplify.

## Usage

Clonewars is written in CoffeeScript using [Meteor](http://meteor.com). Get meteor by following the instructions on the website, then clone this repository.

In `settings.json`, put something like this:

```json
{
  "AWSAccessKeyId": "key",
  "AWSSecretAccessKey": "secret",
  "bucket": "myclonewarsfiles",

  "PG": {
    "url": "my.db.com/dbname"
  }
}
```

The key and secret you use should belong to an application-specific user that only has S3 access to read and write to the bucket you specify here.

You can run the server for development like so:

```
$ meteor --settings settings.json
```

Then you can access the server at localhost:3000.

## How It Works

When you go to the website you'll find a login form asking for your Redshift username and password. This is because Clonewars just checks that the user authenticates with Redshift. This works because of [a postgres meteor accounts adapter](https://github.com/Raynes/meteor-accounts-pg) that I wrote. Makes it really easy to get your Redshift users in.

Users are allowed to upload files to S3 using the credentials you configured, and each username gets its own directory in the bucket. The user gets a list of files with their sizes.

Users can click on a file and they'll see a pop up. This is a COPY command builder form. Each Redshift option is covered (and documentation for each is going to be added) and the copy command is generated from your options. Next iteration will regenerate the copy command for each change you make automatically.

The resulting COPY command will use the credentials you configured.

## Security Concerns

Yes, a user can take the credentials from the copy command they receive and use those to look at/delete any other user's files. Clonewars is _designed_ to be an internal service, and is mostly useful to folks who don't even know what an AWS access key is.
