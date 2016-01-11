# Writing your own plugins #

## A simple example ##

WeShare is a plugin-based component, and only needs little configuration to add other plugins beside the standard ones.

To create your own plugin, you should first have a look at the code of [WeShare's E-Mail plugin](http://code.google.com/p/wesharemobile/source/browse/weshare-mobile-iphone/src/Plugins/Email/WSEmailPlugin.m).

This plugin has only a few methods worth mentioning:

  * it is a subclass of `WSBasePlugin` for some easy callback methods
  * `initWithConfig:(NSDictionary*)aConfig` to act on coniguration settings in the configuration-file.
  * `shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController` as main method to configure the plugin-dialog with input views and presentin it to the user
  * callback-methods for Apple's Email components

WeShares plugins have different levels of complexity. For source code reading, you should try this path:

  1. `WSEmailPlugin` (easiest)
  1. `WSFacebookPlugin`
  1. `WSTwitterPlugin`
  1. `WSDeliciousPlugin` (most complex)

## Implementing your plugin ##

As you can see in the above example, writing your own plugin in not a difficult task. You should check against the following list:

  1. Creat a subclass of `WSBasePlugin` to start with some basic functionality. If subclassing is not an option, you must implement the `WSSharePlugin` protocol.
  1. Set (static) configartion parameters (defaults, API-keys etc.) or typical initialization tasks (e.g. creating a communication engine to a webservice) in the `initWithConfig` method.
  1. Implement the `shareData` method:
    1. Save the `data`-dictionary to an instance variable, you usually need them later (e.g. when sharing fails)
    1. Create a user interface for your plugin and add it as `pluginView` to an instance of `WSSharePluginDialog`.
    1. Fill UI controls with values from `plugin.dataDict` (if subclassing `WSBasePlugin`). For a list of available keys, see `WeShare.h`.
    1. Display the `WSSharePluginDialog` by calling `showInView:(UIView*)aView`. **Note:** the `aView` variable is currently not used, just pass `hostViewController.view` as input.
  1. Post notifications when sharing the content has succeeded or failed:
```
// Sharing success
[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingSuccessfulNotification object: self];

// Sharing fail
NSDictionary* errorDict =  [NSDictionary dictionaryWithObjectsAndKeys: 
                                             errorMessage, kWSSharingFailedErrorMessageKey
                                             error, kWSSharingFailedErrorKey];

[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingFailedNotification
                                                    object: self 
                                                    userInfo: errorDict];
```

# Creating a plugin's UI #

You should extend from `WSPluginViewController` for your own plugin's view controller. This class already has setup listeners when the keyboard is shown and hidden, and offers some hooks for customization.

These hooks include:

  * `pluginDialog`: variable to access the `WSSharePluginDialog` instance in which the plugin view-controller is shown (**Note**: make sure you set this property when initalizing your `pluginViewController`.
  * Scrolling to the currently focused inputs and resizing the embedded view.
  * A `Done`-Button shown above the keyboard to finish input in `UITextView`s.
  * `- (NSArray*)keyboardToolbarItems`: this method should return an array of `UIToolbarItem`s to be inserted into the toolbar above the keyboard. You could, for example, add buttons for taking a picture, inserting the user's current location etc.

[![](http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/supp_by_neofonie_open.png)](http://open.neofonie.de)