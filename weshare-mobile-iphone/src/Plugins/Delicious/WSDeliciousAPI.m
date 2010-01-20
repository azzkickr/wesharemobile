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
 
 
 Created by reiner on 10.12.09.
 
 */

#import "WSDeliciousAPI.h"
#import "MPOAuthAPIRequestLoader.h"
#import "MPURLRequestParameter.h"
#import "DeliciousURLRequest.h"

@interface WSDeliciousAPI ()

//@property (nonatomic, readwrite, retain) NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *credentials;
//
- (void)accessTokenReceived:(NSNotification*)inNotification;

@end

@implementation WSDeliciousAPI

@dynamic credentials;

@synthesize oauthYahooGUID;

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL autoStart:(BOOL)aFlag
{
	self = [super initWithCredentials: inCredentials authenticationURL: inAuthURL andBaseURL: inBaseURL autoStart: aFlag];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	}
	return self;
}

- (void)dealloc
{
	[oauthYahooGUID release];
	[super dealloc];
}

- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	
	// Add the xoauth_yahoo_guid parameter
	NSMutableArray* newInParameters = [NSMutableArray arrayWithArray: inParameters];
	[newInParameters addObject: [[[MPURLRequestParameter alloc] initWithName: @"xoauth_yahoo_guid" andValue: self.oauthYahooGUID] autorelease]];
	
	MPOAuthURLRequest *aRequest = [[DeliciousURLRequest alloc] initWithURL:requestURL andParameters: newInParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];
	
	loader.credentials = self.credentials;
	[loader loadSynchronously:YES];
	
	[loader autorelease];
	[aRequest release];
	
	return loader.data;
}

- (void)accessTokenReceived:(NSNotification *)inNotification
{
	NSDictionary* userInfo = [inNotification userInfo];	
	oauthYahooGUID = [[userInfo objectForKey:@"xoauth_yahoo_guid"] retain];
}

@end
