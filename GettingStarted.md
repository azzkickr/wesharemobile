

# Adding WeShare Mobile for iPhone to your project #

  1. [Download the sourcecode](http://code.google.com/p/sharelogic/source/checkout).
  1. Open the WeShareMobileDemo Xcode project. In the _Groups & Files_ pane, drag the folder "WeShare Mobile" into your project. When asked make sure that "Copy items..." is **deselected**.
  1. In the WeShareMobileDemo Xcode project, from the _WeShare-Plugins_ group, drag the plugins you want to use into your project. You must add the following dependencies to your project:
    * For the Delicious-Plugin: [mpoauthconnection](http://code.google.com/p/mpoauthconnection/), an open source library for connecting to OAuth-secured webservices
      * **Important**: you need to create an API key at [Yahoo Developer Network](https://developer.apps.yahoo.com/dashboard/createKey.html) to use the Delicious-Plugin.
      * You must also **add the `Security.framework`** for this plug-in.
      * In addition, add the file **`oauthAutoConfig.plist`** to your project.
    * For the Facebook-Plugin [Facebook Connect for iPhone](http://wiki.developers.facebook.com/index.php/Facebook_Connect_for_iPhone), a framework to connect to Facebook
      * **Important**: you need to create a [Facebook Application](http://www.facebook.com/developers/apps.php) to use the Facebook-Plugin.
    * For the Twitter-Plugin: [MGTwitterEngine](http://svn.cocoasourcecode.com/MGTwitterEngine), Matt Gemmel's framework for connecting to Twitter's webservice
  1. Add the `WeShare.strings` files to the project:
    1. Select the "Resources" group in the "WeShare" group, right-click and select "Add existing files...".
    1. In the file dialog select **both** the `English.proj/WeShare.strings` and the `German.proj/WeShare.strings` file, and click "OK".
      * When the files display with strange character, right-click on them, select the encoding to be "UTF-16" and click "Reinterpret". (We know, this is tedious, but i18n support in Xcode is still very tedious.)

# Configuration #

WeShare Mobile is configured via `WeShareConfig.plist`, which should reside in your main bundle.

The configuration contains:

  1. Which Plugins to load
  1. Configuration parameters for the plugins (e.g. API keys)

**Example of a `WeShareConfig.plist`**:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Plugins</key>
  <dict>
    <key>WSEmailPlugin</key>
    <dict>
      <key>position</key>
      <integer>1</integer>
      <key>displayName</key>
      <string>E-Mail</string>
      <key>iconImageName</key>
      <string>mail-icon.png</string>
    </dict>
    ...
  </dict>
</dict>
```

In the `Plugins`-node of this XML-file, you list configuration settings for every plugin you want to load:

  * The parent node contains the **class name** of your plugin (e.g. `WSEmailPlugin`)
  * Its childs contain configuration parameters for this plugin, which should include
    * `displayName`: a string representation of your plugin that can be used for text on a button or in a list (e.g. "Send as E-Mail")
    * `iconImageName`: the filename of an icon for the plugin. If you do not specify this parameter, a default icon will be used.
    * Any other parameters you wish to use during plugin initialization, e.g. API-Keys to communicate with Delicious or Facebook.
    * `position`: optional, defines the position in the plugin-list in the share dialog.

# Using WeShare Mobile #

You typically want to display a dialog where the user can select how he wants to share some content. After entering any needed information, the content will be sent to the webservice or alike.

You can display the _share dialog_ by calling some code like this:

```
...
#import "WeShare.h"

@implementation MyClass

...
- (IBAction)share
{

  /*
   ATTENTION: none of your values may be nil in this case, or you anything after 
   this value will be ignored (as nil terminates the list of objects and keys).
   */ 
  NSDictionary* myData = [NSDictionary dictionaryWithObjectsAndKeys:
                                         titleField.text, WSTitleDataDictKey,
                                         messageField.text, kWSMessageDataDictKey,
                                         urlField.text, kWSUrlDataDictKey, nil];

  [[WSShareCenter sharedCenter] shareData: myData hostViewController: myViewController];
}

@end
```

## Adding a toolbar icon ##

To get access via a toolbar item, you can simply call

```

// WMShareCenter.h

+ (UIBarButtonItem*)weShareToolbarItemWithTarget:(id)aTarget action:(SEL)anAction;

```

This is how it looks like:

![http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/weshare-toolbar-item.png](http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/weshare-toolbar-item.png)

# Demo application #

In the `sample` in the sources, you find a sample project that demonstrates the capabilities of the library.

However, you need to make sure to have all third-party-libraries in the `lib` directory. See PluginRequirements for how to get the code.

[![](http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/supp_by_neofonie_open.png)](http://open.neofonie.de)