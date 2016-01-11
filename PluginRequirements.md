# Introduction #

WeShare uses several other open source libraries in its plugins:

  * [mpoauthconneciton](http://code.google.com/p/mpoauthconnection/): an open source library for connecting to OAuth-secured webservices.
  * [MGTwitterEngine](http://svn.cocoasourcecode.com/MGTwitterEngine/): Matt Gemmel's cide for connecting to Twitter's webservice.
  * [Facebook Connect for iPhone](http://wiki.developers.facebook.com/index.php/Facebook_Connect_for_iPhone) for the Facebook-Plugin

# Installation #

In order to use WeShare in your project (or to test the sample application) you need to

  1. Get the code of 3rd party libraries
  1. Add it to your Xcode project
  1. Configure WeShare via `WeShareConfig.plist`

## Getting the code ##

You can get the code for of the libraries via the source links above.

**Tip: downloading in one rush**

  1. You need to have `git` installed to download the Facebook sources.
  1. Open Terminal and go to `weshare/lib`
  1. Enter the following commands:
```
$ svn checkout http://mpoauthconnection.googlecode.com/svn/trunk/ mpoauthconnection
$ svn checkout http://svn.cocoasourcecode.com/MGTwitterEngine/
$ git clone git://github.com/facebook/facebook-iphone-sdk.git
```

## Adding libraries to the project ##

In the links above, you will also find instructions on how to add the libaries to your project. For example, see http://wiki.developers.facebook.com/index.php/Facebook_Connect_for_iPhone for how to add Facebook Connect to your iPhone App.

### Notes to third party libs ###

  * For **MGTwitterEngine**, make sure you set it to use `libxml`:
```
// In MGTwitterEngine.m at the top
#define USE_LIBXML 1
```

# Configururation #

## Create webservice applications ##

Newer webservices, including Facebook and in part Delicious, require you to create special applications to access their platforms.

When you create such an application, you usually get some `apiKey` and `sharedSecret` to access these services.

In WeShare you also need to take these steps:

  * For the Facebook-Plugin, [create a Facebook Application](http://www.facebook.com/developers/apps.php).
  * For the Delicious-Plugin, you need to have a Yahoo account and [create a Project](http://developer.apps.yahoo.com/projects) with the following settings:
    * **Type of Application**: "Contacts, MyBlogLog, Social Directory, Status, Updates, Wretch", as we need to use OAuth
    * **Kind of Application**: "Client/Desktop"
    * **Access Scopes**: select "This app requires access to private user data."
    * **Delicious**: "Read/Write"

## Configure WeShare ##

WeShare is configured through `WeShareConfig.plist`. A sample configuration file can be found in the `sample` directory.

You now need to enter your api-keys and secrets. For the Delicious-plugin, this might look like this:

```
...
<key>WSDeliciousPlugin</key>
<dict>
  <key>displayName</key>
  <string>Bookmark on Delicious</string>
  <key>iconImageName</key>
  <string>delicious-icon.png</string>
  <key>apiKey</key
  <string>dj0yJmk9U1VlSG9aMEM4YU15JmQ9WVdrOWRIazRNWFI0TTJVbWNHbzlN--</string>
  <key>sharedSecret</key>
  <string>18edd7d014c6d744f2a07922c3895dd380416478</string>
  <key>applicationId</key>
  <string>ty81tx3e</string>
</dict>
...
```

[![](http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/supp_by_neofonie_open.png)](http://open.neofonie.de)