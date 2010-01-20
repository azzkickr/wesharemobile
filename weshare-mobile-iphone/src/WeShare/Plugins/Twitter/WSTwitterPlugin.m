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
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-08-11>
 
 */

#import "WeShareGlobal.h"
#import "WSTwitterPlugin.h"
#import "WSTwitterPluginViewController.h"
#import "MGTwitterEngine.h"
#import "UrlRequestOperation.h"

typedef enum {
	WSTwitterCheckUserCredentialsConnection = 1,
	WSTwitterSendUpdateConnection			= 2	
} WSConnectionType;

@implementation WSTwitterPlugin

@synthesize message, credentials, tinyURL;

- (id)initWithConfig:(NSDictionary*)confictDict
{
	self = [super initWithConfig: confictDict];
	if (self != nil) {
		twitterEngine = [[MGTwitterEngine alloc] initWithDelegate: self];
		
		self.credentials = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace: [WSTwitterPlugin defaultProtectionSpace]];
		
		if (credentials) {
			[twitterEngine setUsername: [self.credentials user] password: [self.credentials password]];
		}
		//[twitterEngine setClientName: @"WeShare" version: @"1.0" URL: @"http://code.google.com/p/socialmobile" token: @"socialmobile"];
		
		connectionIdentifierMap = [[NSMutableDictionary alloc] initWithCapacity: 2];
		
		operationQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)dealloc
{	
	self.credentials = nil;
	[connectionIdentifierMap release];
	[twitterEngine release];
	[pluginViewController release];
	[operationQueue release];
	tinyURL = nil;
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController
{	
	self.hostViewController = viewController;
	self.dataDict = [NSMutableDictionary dictionaryWithDictionary: data];
	
	pluginDialog = [[WSSharePluginDialog alloc] initWithDelegate: self];
	pluginDialog.title = [NSString stringWithFormat: WSLocalizedString(@"Share with %@", nil), self.displayName];	
	if (!pluginViewController) {
		pluginViewController = [[WSTwitterPluginViewController alloc] initWithPlugin: self];
	}
	
	pluginViewController.pluginDialog = pluginDialog;
	pluginDialog.pluginView = pluginViewController.view;
	
	self.message = [data valueForKey: kWSTwitterMessagekey];
	if (self.message) {
		pluginViewController.message = self.message;
	}
	
	[pluginDialog showInView: viewController.view];
	
	NSURL* anUrl = [self.dataDict objectForKey: kWSUrlDataDictKey];
	if (!self.message && anUrl) {
		[self insertTinyURL];
	}
}

- (void)postToTwitter:(NSString*)aMessage
{
	if (!aMessage) {
		[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingFailedNotification
															object: self
														  userInfo: [NSDictionary dictionaryWithObject: WSLocalizedString(@"Message must not be empty.", nil)
																								forKey: kWSSharingFailedErrorMessageKey]];
		return;
	}
	
	self.message = aMessage;
	NSString* connectionId;
	NSString* commitMessage;
	WSConnectionType connectionMapKey;
	if (!credentialsValid) {
		connectionId = [twitterEngine checkUserCredentials];
		connectionMapKey = WSTwitterCheckUserCredentialsConnection;
		commitMessage = WSLocalizedString(@"Logging in...", nil);
	} else {
		connectionId = [twitterEngine sendUpdate: self.message];
		connectionMapKey = WSTwitterSendUpdateConnection;
		commitMessage = WSLocalizedString(@"Posting to Twitter...", nil);
	}
	
	/*
	 Trick: use the connectionId as key to later find out which connection failed/succeeded.
	 */
	[connectionIdentifierMap setValue: [NSNumber numberWithInt: connectionMapKey] forKey: connectionId];
	[pluginDialog toggleCommitProgressWithMessage: commitMessage];
}

#pragma mark MGTwitterEngineDelegate

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	WSConnectionType connType = [[connectionIdentifierMap objectForKey: connectionIdentifier] intValue];
	if (connType == WSTwitterCheckUserCredentialsConnection) {
		credentialsValid = YES;
		[pluginDialog toggleCommitProgressWithMessage: WSLocalizedString(@"Posting to Twitter...", nil)];
		[self postToTwitter: self.message];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingSuccessfulNotification object: self];
	}
	[connectionIdentifierMap removeObjectForKey: connectionIdentifier];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
	WSConnectionType connType = [[connectionIdentifierMap objectForKey: connectionIdentifier] intValue];
	if (connType > 0) {
		NSString* errorMessage;
		switch (connType) {
			case WSTwitterCheckUserCredentialsConnection:
				errorMessage = WSLocalizedString(@"Invalid username/password.", nil);	
				break;
			case WSTwitterSendUpdateConnection:
				errorMessage = WSLocalizedString(@"Not able to connect to Twitter.", nil);
				break;
			default:
				break;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingFailedNotification 
															object: self 
														  userInfo: [NSDictionary dictionaryWithObject: errorMessage
																								forKey: kWSSharingFailedErrorMessageKey]];
	} else {
		ZNLog(@"Unknown connection identifier: %@", connectionIdentifier);
	}
	[connectionIdentifierMap removeObjectForKey: connectionIdentifier];
}

#pragma mark WSSharePluginDialogDelegate

- (void)didPressCommitInDialog:(WSSharePluginDialog*)dialog
{	
	if (pluginViewController.inputsValid) {
		[self postToTwitter: pluginViewController.message];
	}
}

- (void)didDismissDialog:(WSSharePluginDialog *)dialog
{
	[pluginViewController release], pluginViewController = nil;
	[pluginDialog release], pluginDialog = nil;
}

#pragma mark Credential Handling

- (void)setUsername:(NSString*)username password:(NSString*)password remember:(BOOL)aFlag
{
	if (![username isEqualToString: [twitterEngine username]] || ![password isEqualToString: [twitterEngine password]]) {
		[twitterEngine setUsername: username password: password];
		if (aFlag) {
			NSURLCredential* newCredentials = [NSURLCredential credentialWithUser: username
																		 password: password
																	  persistence: (aFlag ? NSURLCredentialPersistencePermanent : NSURLCredentialPersistenceForSession)];
			[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential: newCredentials
																forProtectionSpace: [WSTwitterPlugin defaultProtectionSpace]];
			self.credentials = newCredentials;
		}
		credentialsValid = NO;
	}
}

- (NSString*)username
{
	return [twitterEngine username];
}

- (NSString*)password
{
	return [twitterEngine password];
}

- (void)clearCredentials
{
	credentialsValid = NO;
	[[NSURLCredentialStorage sharedCredentialStorage] removeCredential: self.credentials
													forProtectionSpace: [WSTwitterPlugin defaultProtectionSpace]];
	self.credentials = nil;
}

+ (NSURLProtectionSpace*)defaultProtectionSpace
{
	return [[[NSURLProtectionSpace alloc] initWithHost: @"Twitter"
												  port: 443
											  protocol: @"https"
												 realm: @"Twitter API"
								  authenticationMethod: nil] autorelease];
}

#pragma mark TinyURL Support

- (void)insertTinyURL
{
	if (!tinyURL) {
		NSString *alias = [NSString stringWithFormat:@"y%08x", ((int)time(NULL))];
		NSURL* anUrl = [self.dataDict objectForKey: kWSUrlDataDictKey];
		if (anUrl) {
			// We are optimistic: if requesting the URL fails, tinyURL is set to nil again
			tinyURL = [[NSURL URLWithString: [NSString stringWithFormat: @"http://tinyurl.com/%@", alias]] retain];
			UrlRequestOperation* op = [[[UrlRequestOperation alloc] initWithUrl: [NSString stringWithFormat:@"http://tinyurl.com/create.php?url=%@&alias=%@", anUrl, alias] 
																	  delegate: self] autorelease];
			[operationQueue addOperation: op];
		}
	} else {
		[pluginViewController insertText: [NSString stringWithFormat: @"%@ ", [tinyURL absoluteString]]];
	}

}

#pragma mark UrlRequestOperationDelegate

- (void)requestOperation:(UrlRequestOperation*)operation didFinishWithData:(NSData*)data
{
	if (!data) {
		tinyURL = nil;
	} else {
		NSString* theText = [NSString stringWithFormat: @"%@ ", [tinyURL absoluteString]];
		[pluginViewController performSelectorOnMainThread: @selector(insertText:) withObject: theText waitUntilDone: NO];
	}
}

- (void)requestOperation:(UrlRequestOperation*)operation didFailWithError:(NSError*)error
{
	tinyURL = nil;
}

@end
