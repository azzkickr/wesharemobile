/*
 
 WeShare Mobile for iPhone - A library to easily share information on various networks

 WeShare Mobile for iPhone - Copyright (C) 2009, 2010 neofonie Technologieentwicklung 
 und Informationsmanagement GmbH (neofonie), http://open.neofonie.de
 
 neofonie provides this program under a dual license model designed to meet the 
 development and distribution needs of both commercial distributors and open source.
  
 For the use as open source you can redistribute it and/or modify 
 this program under the terms of the GNU General Public License version 3  
 as published by the Free Software Foundation, either of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 You may also purchase a commercial license to use this program as non-GPL.
 Please contact open@neofonie.de for further information and assistance. Purchasing a 
 commercial license means that the GPL does not apply, and a commercial license
 (neofonie Commercial Source Code License Version 1.0, NCSL v1.0) includes the 
 assurances that distributors typically find in commercial distribution agreements.
 
 
 */

// Created by Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-09-22>

#import "WeShareGlobal.h"
#import "WSFacebookPlugin.h"
#import "FBConnect/FBConnect.h"

/*
 Taken from Facebook SDK/FBDialog.m
 */
#define kFacebookDialogTransitionDuration 0.3;

@interface WSFacebookPlugin ()

- (void)createSession;
- (void)showStreamDialog;

@end

@implementation WSFacebookPlugin

@synthesize apiKey;
@synthesize appSecret;
@synthesize useSessionProxy;
@synthesize sessionProxyURL;

- (id)initWithConfig:(NSDictionary*)configDict
{
	self = [super initWithConfig:configDict];
	if (self != nil) {
		self.apiKey = [self.config objectForKey: @"apiKey"];
		self.useSessionProxy = [[self.config objectForKey: @"useSessionProxy"] boolValue];
		
		if (self.useSessionProxy) {
			self.sessionProxyURL = [NSURL URLWithString: [self.config objectForKey: @"sessionProxyURL"]];
		} else {
			self.appSecret = [self.config objectForKey: @"appSecret"];
		}
		
		[self createSession];
	}
	return self;
}

- (void)dealloc
{
	[facebookSession.delegates removeObject: self];
	[facebookSession logout];
	[facebookSession release];
    [apiKey release], apiKey = nil;
    [sessionProxyURL release], sessionProxyURL = nil;
	
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController
{
	self.dataDict = [NSMutableDictionary dictionaryWithDictionary: data];
	self.hostViewController = viewController;
	if (![facebookSession isConnected]) {
		// The user has to login first
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession: facebookSession] autorelease];
		dialog.delegate = self;
		[dialog show];
	} else {
		[facebookSession resume];
		[self showStreamDialog];
	}
}

- (void)showStreamDialog
{
	FBStreamDialog* dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.userMessagePrompt = WSLocalizedString(@"Share this with Facebook", nil);	
	dialog.attachment = [self streamDialogAttachment];
	[dialog show];
}

- (NSString*)streamDialogAttachment
{		
	NSString* result;
	
	/*
	 streamParamsDict is a mapping of WeShare shareDict keys (see WeShare.h) to
	 Facebook attachment keys (see http://wiki.developers.facebook.com/index.php/Attachment_%28Streams%29)
	 */
	NSDictionary* streamParamsDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"name", kWSTitleDataDictKey,
									  @"href", kWSUrlDataDictKey,
									  @"description", kWSDescriptionDictKey,
									  @"media", kWSImageURLDictKey,
									  @"caption", kWSFacebookCaptionKey,
									  nil];
	
	// Create a JSON string that only contains actually existing parameters
	
	NSMutableArray* actualParameters = [[NSMutableArray alloc] init];
	
	for (NSString* key in [streamParamsDict allKeys]) {
		NSString* value = [self.dataDict objectForKey: key];
		
		if (value) {
			NSString* streamKey = [streamParamsDict objectForKey: key];
			// Special handling for media items
			if ([streamKey isEqualToString: @"media"]) {
				NSString* href = [[self.dataDict objectForKey: kWSUrlDataDictKey] absoluteString];
				value = [NSString stringWithFormat: @"[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}]", value, href];
				
				[actualParameters addObject: [NSString stringWithFormat: @"\"%@\":%@", streamKey, value]];
			} else {				
				[actualParameters addObject: [NSString stringWithFormat: @"\"%@\":\"%@\"", streamKey, value]];
			}
		}
	}
	
	NSString* parameterString = [actualParameters componentsJoinedByString: @","];
	result = [NSString stringWithFormat: @"{%@}", parameterString];
	
	[actualParameters release];
	return result;
}

- (void)createSession
{
	if (self.useSessionProxy) {
		facebookSession = [[FBSession sessionForApplication: self.apiKey
											getSessionProxy: [self.sessionProxyURL absoluteString]
												   delegate: self] retain];
	} else {
		facebookSession = [[FBSession sessionForApplication: self.apiKey
													 secret: self.appSecret
												   delegate: self] retain];
	}
}

#pragma mark FBDialogDelegate methods

- (void)dialogDidSucceed:(FBDialog*)dialog {
	if ([dialog isKindOfClass: [FBLoginDialog class]]) {
		[self showStreamDialog];
	}
	if ([dialog isKindOfClass: [FBStreamDialog class]]) {
		/*
		 Show the result screen manually.
		 
		 We release the pluginDialog in the delegate callback method (didDismissDialog:)
		*/
		WSSharePluginDialog* pluginDialog = [[WSSharePluginDialog alloc] init];
		pluginDialog.pluginView = [[[UIView alloc] init] autorelease];
		pluginDialog.delegate = self;
		pluginDialog.title = @"Share with Facebook";
		[pluginDialog showInView: self.hostViewController.view animated: NO];
		
		[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingSuccessfulNotification object: self];
	}
}

- (void)dialogDidCancel:(FBDialog*)dialog {
	[[NSNotificationCenter defaultCenter] postNotificationName: kWSSharingCancelledNotification object: self];
}

#pragma mark FBSessionDelegate methods

- (void)session:(FBSession*)session didLogin:(FBUID)uid
{
	facebookSession = [session retain];
	NSLog(@"User with id %lld logged in.", uid);
}

#pragma mark WSDialogDelegate

- (void)didDismissDialog:(WSDialog*)dialog
{
	[dialog release];
}

@end
