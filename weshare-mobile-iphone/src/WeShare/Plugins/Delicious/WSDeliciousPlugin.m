/*
 
 WeShare Mobile for iPhone - A library to easily share information on various networks
 
 WeShare Mobile for iPhone - Copyright (C) 2009, 2010 Reiner Pittinger, Initiative neofonie open, 
 neofonie Technologieentwicklung und Informationsmanagement GmbH, http://open.neofonie.de
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 You may obtain a commercial licence to use this library in non-GPL projects. Please contact open@neofonie.de for further information and assistance. 
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-09-28>
 
 */

#import "WSDeliciousPlugin.h"
#import "WeShareGlobal.h"
#import "WSDeliciousPluginViewController.h"
#import "UrlRequestOperation.h"
#import "MPOAuthAPI.h"
#import "WSDeliciousAPI.h"
#import "MPOAuthSignatureParameter.h"
#import "MPOAuthAuthenticationMethod.h"
#import "MPOAuthAuthenticationMethodOAuth.h"
#import "NSURL+MPURLParameterAdditions.h"

#define kUseOAuthKey @"WeShare.WSDeliciousPlugin.UseOAuth"

#define kDeliciousBaseUrl @"http://api.del.icio.us/v2/"

#define kDeliciousAccount @"delicious.com"

@interface WSDeliciousPlugin()

- (void)processDeliciousResponse:(NSData*)responseData;
- (void)oAuthAccessTokenReceived:(NSNotification*)aNotification;
- (void)postFailNotificationWithUserInfo:(NSDictionary*)userInfo;

@end

@implementation WSDeliciousPlugin

@synthesize useOAuth;

- (id)initWithConfig:(NSDictionary*)configDict
{
	self = [super initWithConfig: configDict];
	if (self != nil) {
		credentials = [[[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace: [WSDeliciousPlugin defaultProtectionSpace]] retain];
		if (credentials) {
			ZNLog(@"Username: %@", [credentials user]);
		}
		operationQueue = [[NSOperationQueue alloc] init];
		
		// OAuth engine initialization
		self.useOAuth = [[[NSUserDefaults standardUserDefaults] objectForKey: kUseOAuthKey] boolValue];
		
		NSDictionary *oAuthCredentials = [NSDictionary dictionaryWithObjectsAndKeys: [self.config objectForKey: @"apiKey"], kMPOAuthCredentialConsumerKey,
										  [self.config objectForKey: @"sharedSecret"], kMPOAuthCredentialConsumerSecret,
										  kMPOAuthSignatureMethodPlaintext, kMPOAuthSignatureMethod, 
										  nil];
		
		oauthAPI = [[WSDeliciousAPI alloc] initWithCredentials: oAuthCredentials
										 authenticationURL: [NSURL URLWithString: @"https://api.login.yahoo.com/oauth/v2"]
												andBaseURL: [NSURL URLWithString: kDeliciousBaseUrl]
													 autoStart: NO];
		
		oauthAPI.signatureScheme = MPOAuthSignatureSchemePlainText;
		oauthAuthMethod = [(MPOAuthAuthenticationMethodOAuth*)oauthAPI.authenticationMethod retain];
		oauthAuthMethod.delegate = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oAuthAccessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSUserDefaults standardUserDefaults] setBool: self.useOAuth forKey: kUseOAuthKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[credentials release];
	[pluginViewController release];
	
	[oauthAPI release];
	[oauthAuthMethod release];
	[operationQueue release];
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController
{
	self.dataDict = [NSMutableDictionary dictionaryWithDictionary: data];
	self.hostViewController = viewController;
	
	if (!pluginViewController) {
		pluginViewController = [[WSDeliciousPluginViewController alloc] initWithPlugin: self];
	}
	
	// ???: Move this as default code to superclass?
	if (!pluginDialog) {
		pluginDialog = [[WSSharePluginDialog alloc] initWithDelegate: pluginViewController];
	}
	pluginDialog.title = [NSString stringWithFormat: WSLocalizedString(@"Share with %@", nil), self.displayName];
	
	pluginViewController.pluginDialog = pluginDialog;
	pluginDialog.pluginView = pluginViewController.view;
	[pluginDialog showInView: viewController.view];
}

- (void)didDismissDialog:(WSSharePluginDialog *)dialog
{
	// If user authentication could not be finished, discard server credentials
	if (oauthAPI.authenticationState != MPOAuthAuthenticationStateAuthenticated) {
		[oauthAPI discardCredentials];
	}
	
	[pluginViewController release], pluginViewController = nil;
	[pluginDialog release], pluginDialog = nil;
}

- (void)postUrl:(NSString*)url withTitle:(NSString*)title
{
	// Update the dataDict if we need to come back to this function
	[self.dataDict setObject: url forKey: kWSUrlDataDictKey];
	[self.dataDict setObject: title forKey: kWSTitleDataDictKey];
	
	if (!pluginViewController.inputsValid) {
		return;
	}
	
	// TODO: More parameters (tags etc.)
	NSArray* parameters = [NSArray arrayWithObjects: 
						   [[[MPURLRequestParameter alloc] initWithName: @"description" andValue: title] autorelease],
						   [[[MPURLRequestParameter alloc] initWithName: @"url" andValue: url] autorelease], 
						   nil];
	
	[pluginDialog toggleCommitProgressWithMessage: WSLocalizedString(@"Posting to Delicious...", nil)];
		
	if (self.useOAuth) {
		if (![oauthAPI isAuthenticated]) {
			[pluginDialog toggleCommitProgressWithMessage: WSLocalizedString(@"Logging in...", nil)];
			[oauthAPI authenticate];
		} else {			
			// FIXME: This request is synchronous :(
			NSData* data = [oauthAPI dataForMethod: @"posts/add" withParameters: parameters];
			[self processDeliciousResponse: data];
		}
	} else {
		// Code for v1-Posting (original Delicious accounts)
		
		NSURL* theUrl = [[NSURL URLWithString: @"https://api.del.icio.us/v1/posts/add"] urlByAddingParameters: parameters];
		
		UrlRequestOperation* op = [[[UrlRequestOperation alloc] initWithUrl: [theUrl absoluteString] delegate: self] autorelease];
		op.username = [credentials user];
		op.password = [credentials password];
		[operationQueue addOperation: op];
	}
}

- (void)processDeliciousResponse:(NSData*)responseData
{
	NSString* response = [[[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding] autorelease];
	ZNLog(@"Response: %@", response);
	
	NSRange range = [response rangeOfString: @"code=\"access denied\""];
	if (range.location != NSNotFound) {
		[self postFailNotificationWithUserInfo: [NSDictionary dictionaryWithObject: WSLocalizedString(@"Invalid username/password.", nil) forKey: kWSSharingFailedErrorMessageKey]];
	}
	
	range = [response rangeOfString: @"code=\"done\""];
	if (range.location != NSNotFound) {
		[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingSuccessfulNotification object: self];
	} else {
		[self postFailNotificationWithUserInfo: [NSDictionary dictionaryWithObject: response forKey: kWSSharingFailedErrorMessageKey]];
	}
}

- (void)postFailNotificationWithUserInfo:(NSDictionary*)userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingFailedNotification 
														object: self 
													  userInfo: userInfo];
}

#pragma mark Credential handling

- (void)setUsername:(NSString*)aUsername password:(NSString*)aPassword remember:(BOOL)doRemember
{
	if (!aUsername && !aPassword) {
		[self clearCredentials];
		return;
	}
	[credentials release];
	credentials = [[NSURLCredential credentialWithUser: aUsername 
											 password: aPassword 
										  persistence: (doRemember ? NSURLCredentialPersistencePermanent : NSURLCredentialPersistenceForSession)] retain];
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential: credentials forProtectionSpace: [WSDeliciousPlugin defaultProtectionSpace]];
}

- (NSString*)username
{
	NSString* result = @"";
	if (credentials && [credentials user]) {
		result = [credentials user];
	}
	return result;
}

- (NSString*)password
{
	NSString* result = @"";
	if (credentials && [credentials password]) {
		result = [credentials password];
	}
	return result;
}

- (BOOL)rememberCredentials
{
	if (credentials) {
		return [credentials persistence] == NSURLCredentialPersistencePermanent;
	} else {
		return NO;
	}
}

- (void)setRememberCredentials:(BOOL)doRemember
{
	[self setUsername: [self username] password: [self password] remember: doRemember];
}

+ (NSURLProtectionSpace*)defaultProtectionSpace
{
	return [[[NSURLProtectionSpace alloc] initWithHost: @"del.icio.us"
												  port: 443
											  protocol: @"https"
												 realm: @"del.icio.us API"
								  authenticationMethod: nil] autorelease];
}

- (void)clearCredentials
{
	[[NSURLCredentialStorage sharedCredentialStorage] removeCredential: credentials forProtectionSpace: [WSDeliciousPlugin defaultProtectionSpace]];
}

/*
 Always discard existing OAuth credentials when this setting is changed
 */
- (void)setUseOAuth:(BOOL)aFlag
{
	useOAuth = aFlag;
	[oauthAPI discardCredentials];
}

#pragma mark MPOAuthAuthenticationMethodOAuthDelegate

- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL {
	pluginViewController.userAuthURL = inAuthURL;
	[pluginViewController presentUserAuthViewController];
	
	return NO;
}

- (NSURL*)callbackURLForCompletedUserAuthorization
{
	return [NSURL URLWithString: @"oob"];
}

/*
 Performs the same call like [MPOAuthApi autenticate], but supplying the verifier token
 */
- (void)authenticateWithVerifierToken:(NSString*)verifierToken
{
	[pluginViewController dismissUserAuthViewController];
	
	MPURLRequestParameter* verifierParameter = [[[MPURLRequestParameter alloc] initWithName: @"oauth_verifier" andValue: verifierToken] autorelease];
	[oauthAPI performMethod: nil 
					  atURL: oauthAuthMethod.oauthGetAccessTokenURL 
			 withParameters: [NSArray arrayWithObject: verifierParameter]
				 withTarget: oauthAPI andAction: nil];
}

- (void)oAuthAccessTokenReceived:(NSNotification*)aNotification
{
	[pluginDialog toggleCommitProgressWithMessage: WSLocalizedString(@"Posting to Delicious...", nil)];
	// IMPORTANT: We need to switch the signature method for any further requests.
	oauthAPI.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;
	
	// Repost message
	[self postUrl: [self.dataDict objectForKey: kWSUrlDataDictKey] withTitle: [self.dataDict objectForKey: kWSTitleDataDictKey]];
}

- (void)authenticationDidFailWithError:(NSError *)error
{
	if (pluginViewController.userAuthViewShown) {
		[pluginViewController dismissUserAuthViewController];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingFailedNotification
														object: self
													  userInfo: [NSDictionary dictionaryWithObject: [error localizedDescription]
																							forKey: kWSSharingFailedErrorMessageKey]];
}

#pragma mark UrlRequestOperationDelegate

- (void)requestOperation:(UrlRequestOperation*)operation didFinishWithData:(NSData*)data
{
	[self performSelectorOnMainThread: @selector(processDeliciousResponse:) withObject: data waitUntilDone: NO];
}

- (void)requestOperation:(UrlRequestOperation*)operation didFailWithError:(NSError*)error
{
	NSString* errorMessage;
	
	int errorCode = [error code];
	switch (errorCode) {
		case NSURLErrorTimedOut:
			errorMessage = WSLocalizedString(@"Could not reach service.", nil);
			break;
		case NSURLErrorUserCancelledAuthentication:
			errorMessage = WSLocalizedString(@"Invalid username/password.", nil);
			break;
		default:
			errorMessage = WSLocalizedString(@"Unknown error.", nil);
			break;
	}
	
	[self performSelectorOnMainThread: @selector(postFailNotificationWithUserInfo:) 
						   withObject: [NSDictionary dictionaryWithObject: errorMessage forKey: kWSSharingFailedErrorMessageKey] 
						waitUntilDone: NO];
}

@end
