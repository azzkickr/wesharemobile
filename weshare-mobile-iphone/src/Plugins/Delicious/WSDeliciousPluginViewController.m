/*
 
 WeShare for iPhone - A library to easily share information on various networks
 
 WeShare for iPhone - Copyright (C) 2009, Reiner Pittinger, Initiative neofonie open, 
 neofonie Technologieentwicklung und Informationsmanagement GmbH (neofonie), http://open.neofonie.de
 
 neofonie provides this program under a dual license model designed to meet the development and distribution needs of both commercial distributors and open source projects.
 
 For the use in open source projcts you can redistribute it and/or modify
 this program under the terms of the GNU General Public License version 3 as published by the Free Software Foundation, either of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 You may also purchase a commercial licence to use this program in non-GPL projects. Please contact open@neofonie.de for further information and assistance. Purchasing a commercial license means that the GPL does not apply, and a commercial license (neofonie Commercial Source Code License Version 1.0), NCSL v1.0 includes the assurances that distributors typically find in commercial distribution agreements.
 
 
 Created by reiner on 19.11.09.
 
 */

#import "WSDeliciousPluginViewController.h"
#import "WeShareGlobal.h"
#import "WSDeliciousPlugin.h"
#import "UserAuthViewController.h"

@implementation WSDeliciousPluginViewController

@synthesize plugin, userAuthURL, userAuthViewShown;

- (id)initWithPlugin:(WSDeliciousPlugin*)aPlugin
{
	self = [super init];
	if (self != nil) {
		plugin = [aPlugin retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scrollToLoginInputs)
													 name:UIKeyboardDidShowNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[plugin release];
	
	[userAuthViewController release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!plugin) {
		[[WSShareCenter sharedCenter] pluginForClass: [WSDeliciousPlugin class]];
	}
	
	titleField.text = [plugin.dataDict objectForKey: kWSTitleDataDictKey];	
	urlField.text = [[plugin.dataDict objectForKey: kWSUrlDataDictKey] absoluteString];
	
	usernameField.text = [plugin username];
	passwordField.text = [plugin password];
	rememberCredentialsSwitch.on = plugin.rememberCredentials;
	
	oAuthInfoView.font = [UIFont systemFontOfSize: [UIFont smallSystemFontSize]];
	oAuthInfoView.text = WSLocalizedString(@"Set this switch to on if you use your Yahoo ID to login to Delicious.", nil);
	
	BOOL useOAuth = plugin.useOAuth;
	
	useOAuthSwitch.on = useOAuth;
	credentialsContainerView.hidden = useOAuth;
	
	// i18n
	titleLabel.text = WSLocalizedString(@"Title", nil);
	urlLabel.text = WSLocalizedString(@"URL", nil);
	oauthSwitchLabel.text = WSLocalizedString(@"Login with Yahoo", nil);
	usernameLabel.text = WSLocalizedString(@"Username", nil);
	passwordLabel.text = WSLocalizedString(@"Password", nil);
	rememberLabel.text = WSLocalizedString(@"Remember", nil);
}

- (IBAction)updateLoginMethod
{
	BOOL useOAuth = useOAuthSwitch.on;
	plugin.useOAuth = useOAuth;
	
	credentialsContainerView.hidden = useOAuth;
}

- (void)didPressCommitInDialog:(WSSharePluginDialog *)dialog
{
	if (!useOAuthSwitch.on) {
		[plugin setUsername: usernameField.text password: passwordField.text remember: rememberCredentialsSwitch.on];
	}
	if (self.inputsValid) {
		[plugin postUrl: urlField.text withTitle: titleField.text];
	}
	pluginDialog.commitButton.enabled = self.inputsValid;
}

- (void)didDismissDialog:(WSSharePluginDialog *)dialog
{
	if (userAuthViewShown) {
		[self dismissUserAuthViewController];
	}
	[plugin didDismissDialog: dialog];
}

- (IBAction)rememberCredentialsToggled
{
	[plugin setUsername: usernameField.text password: passwordField.text remember: rememberCredentialsSwitch.on];
}

- (IBAction)clearCredentials
{
	usernameField.text = @"";
	passwordField.text = @"";
	[plugin clearCredentials];
}

#pragma mark UserAuthViewController methods

- (void)presentUserAuthViewController
{
	userAuthViewShown = YES;
	
	if (!userAuthViewController) {
		userAuthViewController = [[UserAuthViewController alloc] initWithURL: self.userAuthURL];
	}
	[self.view addSubview: userAuthViewController.view];
	
	CGRect frame = [self.view bounds];
	frame.origin.y += frame.size.height;
	
	userAuthViewController.view.frame = frame;
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: kWSTransitionDuration/1.5];
	
	frame.origin.y = 0;
	userAuthViewController.view.frame = frame;
	[UIView commitAnimations];
}

- (void)dismissUserAuthViewController
{
	userAuthViewShown = NO;
	
	if (userAuthViewController) {
		CGRect frame = [self.view bounds];
		frame.origin.y += frame.size.height;
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: kWSTransitionDuration/1.5];
		[UIView setAnimationDidStopSelector: @selector(postDismissUserAuthViewController)];
		
		userAuthViewController.view.frame = frame;
		[UIView commitAnimations];
	}
}

- (void)postDismissUserAuthViewController
{
	[userAuthViewController.view removeFromSuperview];
}

- (BOOL)inputsValid
{
	BOOL result = NO;
	
	UIColor* errorColor = WSErrorColor();
	UIColor* normalColor = [UIColor blackColor];
	
	BOOL titleOK = ![titleField.text isEmpty];
	BOOL urlOK = ![urlField.text isEmpty];
	
	BOOL usernameOK = YES;
	BOOL passwordOK = YES;
	
	if (!useOAuthSwitch.on) {
		usernameOK = ![[plugin username] isEmpty];
		passwordOK = ![[plugin password] isEmpty];
	}
	
	titleLabel.textColor = titleOK ? normalColor : errorColor;
	urlLabel.textColor = urlOK ? normalColor : errorColor;
	usernameLabel.textColor = usernameOK ? normalColor : errorColor;
	passwordLabel.textColor = passwordOK ? normalColor : errorColor;
		
	result = titleOK && urlOK && usernameOK && passwordOK;
	return result;
}

- (void)scrollToLoginInputs
{
	if (!useOAuthSwitch.on && (self.activeField == usernameField || self.activeField == passwordField)) {
		[scrollView scrollRectToVisible: credentialsContainerView.frame animated: YES];
	}
}

@end