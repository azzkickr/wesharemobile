# Overview #

WeShare Mobile for iPhone has three main components:

  1. `WSShareCenter`: a central registry for accessing the plugins
  1. UI: classes to present a decent user interface to use WeShare
  1. Plugins: software modules to send the data to different (web-)services
  1. Utility-classes like `NSString`-additions

# Framework-Parts #

## WSShareCenter ##

!WSShareCenter manages plugin initialization and offers simple methods to display the share dialog.

When initialized (it implements the singleton pattern), it looks for a file called `WeShareConfig.plist` which contains the plugins to be loaded and configuration parameters.

The configuration paramaters should include the following parameters:

  * `displayName`: a string that can be used in the plug-in list in !SMShareDialog
  * `iconImageName`: the filename of an icon for the plugin. If you do not specify this parameter, a default icon will be used.
  * `position`: optional, defines the position in the plugin-list in the share dialog.
  * other parameters: these may include values like `apiKey` and `sharedSecred` that, for instance, are necessary to talk to the Facebook API.

## UI: WSShareDialog and WSSharePluginDialog ##

<img src='http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/WeShare_1.png' width='200'>
<img src='http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/WeShare_2.png' width='200'>
<img src='http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/WeShare_3.png' width='200'>

!WSShareDialog is a dialog where the user can select the service he wants to use.<br>
<br>
!WSSharePluginDialog presents the UI of the plugin itself.<br>
<br>
To display the share dialog, you can use the method <code>[[WSShareCenter sharedCenter] shareData: someData hostViewController: aHostViewController]</code>.<br>
<br>
<b>Note:</b> The parameter <code>hostViewController</code> is currently not used, but may be in the future, e.g. for displaying the share dialog as action sheet or modal view.<br>
<br>
You can also create your own instance of the share dialog and get the delegate events:<br>
<br>
<pre><code>NSDictionary* shareData = ...;<br>
<br>
shareDialog = [[WSShareDialog alloc] init];<br>
// Set a delegate so you can release the dialog when it is closed<br>
shareDialog.delegate = self;<br>
shareDialog.shareData = someData;<br>
[shareDialog showInView: self.view];<br>
<br>
  /*<br>
   * To release the dialog right after it has been closed, implement the following method<br>
   * defined in the `WSDialogDelegate` protocol:<br>
   */<br>
- (void)didDismissDialog:(WSDialog*)dialog {<br>
  [dialog release];<br>
}<br>
</code></pre>

!WSSharePluginDialog is a container for plugin UI with some commonly needed interface elements and hooks to add your own buttons. The Twitter-plugin, for example, adds an !URL-button to the toolbar above the keyboard.<br>
<br>
<img src='http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/twitterPlugin-keyboardToolbar.png'>

Note that the plugin-dialog is retained (and memory managed) <b>by the plugin</b>!<br>
<br>
<h2>Plugins</h2>

WeShare Mobile comes with four plugins for Facebook, Twitter, E-Mail and Delicious. See the PlugIns-page for some implementation details.<br>
<br>
Each plugin conforms to the <code>WSSharePlugin</code> protocol with basically one important method:<br>
<br>
<pre><code>- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)hostViewController;<br>
</code></pre>

<ul><li><code>data</code> is a dictionary with specific keys and values to be presented in the plug-in dialog and send to the service. As there is common data for the services (e.g. title, url or message), some default keys are defined in <code>WeShare.h</code> (e.g. <code>kWSTitleDataDictKey</code>).<br>
</li><li><code>hostViewController</code> is currently not used, but may be later to offer showing the dialogs as action sheets or modal views.</li></ul>

In the <code>shareData</code>-method, you usually create an instance of <code>WSSharePluginDialog</code> and a subclass of <code>WSPluginViewController</code> to display elements to adjust the content being posted.<br>
<br>
A easiest implementation of the <code>shareData:hostViewController:</code> method can be found in the <code>WSEMailPlugin</code>:<br>
<br>
<pre><code>- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController<br>
{	<br>
	// Currently not used<br>
        self.hostViewController = viewController;<br>
	NSString* subject = [data valueForKey: kSMTitleDataDictKey];<br>
	NSString* messageBody = [data valueForKey: kSMMessageDataDictKey];<br>
	<br>
	// Prepare the In-App E-Mail Dialog<br>
	mailController = [[MFMailComposeViewController alloc] init];<br>
	...		<br>
	<br>
	pluginDialog = [[WSSharePluginDialog alloc] init];<br>
	pluginDialog.delegate = self;<br>
	...<br>
	pluginDialog.pluginView = mailController.view;<br>
	<br>
	// Note: viewController.view is currently not used<br>
	[pluginDialog showInView: viewController.view];<br>
}<br>
</code></pre>

<h2>Writing your own plugins</h2>

See the PlugIns page to see how to write your own plugins.<br>
<br>
<a href='http://open.neofonie.de'><img src='http://wesharemobile.googlecode.com/hg/weshare-mobile-iphone/docs/supp_by_neofonie_open.png' /></a>