# Introduction #

WeShare comes with four basic plugins for the most popular channels to share information. This page gives you some details about the implementation of these plugins.

See PlugIns on how to create your own plugins.

The `WSEmailPlugin` is not discussed here, as it is already explained on the PlugIns page.

# Facebook Plugin #

Much of the communication with Facebook's webservice is managed through Facebook Connect.

The only slightly more complex function is `- (NSString*)streamDialogAttachment`, which creates the !JSON string for postings on a users wall. The format is described in the [developer wiki](http://wiki.developers.facebook.com/index.php/Attachment_%28Streams%29).

To create a modified attachment string, just subclass from the Facebook-Plugin and overwrite this method.

# Twitter Plugin #

Again, the extensive part of this plugin is managed my Matt Gemmells great [MGTwitterEngine](http://mattgemmell.com/source).

Complexity is added through asynchronous URL requests, which is simplified by the helper class `UrlRequestOperation` which encapsulates the URL connection handling and simplifies access. !WSTwitterPlugin also implements callback methods of !MGTwitterEngine.

Currently `NSURLCredentialStorage` is used to save the user's account data.

# Delicious Plugin #

This plugin is the most complicated, as Yahoo uses [OAuth](http://oauth.net/) for newer Delicious accounts, an extensive authenication process (good explained on the [Fire Eagle webpage](http://fireeagle.yahoo.net/developer/documentation/oauth_best_practice).

Again, open source projects take away much of the pain: [mpoauthconnection](http://code.google.com/p/mpoauthconnection/) makes accessing OAuth secured services much easier. A step-by-step-example of how to communicate with Delicious can be found [here](http://delicious.com/help/oauthapi).

## Modified OAuth path ##

It not yet authenticated, the plugin will display a Yahoo login page where the user has to allow access to his bookmarks.

Acutally, this page should be displayed in Safari to allow the user to verify the URL of the webpage.

However, we did't want to cut the workflow by quitting the app that uses WeShare, opening Safari and later opening the app again.
Our approach is to open the page in an embedded webview and, after the user allowed access, parse the _verifier code_ via JavaScript.

In the future, you may be able to select between this approach and the more "clean" way of "Quit/Safari/Restart".

[![](http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/supp_by_neofonie_open.png)](http://open.neofonie.de)