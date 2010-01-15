/*
 
 WeShare for iPhone - A library to easily share information on various networks
 
 WeShare for iPhone - Copyright (C) 2009, Reiner Pittinger, Initiative neofonie open, 
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

#import "WeShareGlobal.h"
#import "WSBasePlugin.h"
#import "UrlRequestOperation.h"
#import "MPOAuthAPI.h"
#import "MPOAuthAuthenticationMethodOAuth.h"

#define kWSDeliciousPluginServerResponseKey @"WSDeliciousPluginServerResponse"
#define kWSUrlRequestOperationErrorKey @"WSUrlRequestOperationError"

@class WSDeliciousPluginViewController, UserAuthViewController, MPOAuthAPI;

@interface WSDeliciousPlugin : WSBasePlugin <UrlRequestOperationDelegate, WSSharePluginDialogDelegate, MPOAuthAuthenticationMethodOAuthDelegate> {
		
	NSOperationQueue* operationQueue;
	
	WSSharePluginDialog* pluginDialog;
	
	WSDeliciousPluginViewController* pluginViewController;
	
	UINavigationController* navController;
	
	// Credentials if not using OAuth
	NSURLCredential* credentials;
	BOOL rememberCredentials;
	
	BOOL useOAuth;
	MPOAuthAPI* oauthAPI;
	MPOAuthAuthenticationMethodOAuth* oauthAuthMethod;
}

@property (nonatomic, assign) BOOL rememberCredentials;
@property (nonatomic, assign) BOOL useOAuth;

// TODO Create a configurable request object with all available Delicious attributes
- (void)postUrl:(NSString*)url withTitle:(NSString*)title;

- (NSString*)username;
- (NSString*)password;
- (void)setUsername:(NSString*)username password:(NSString*)password remember:(BOOL)aFlag;
- (void)clearCredentials;
/*
 Returns the protection space instance used for storing the user's credentials if NOT using OAuth (usually for old Delicious logins).
 */
+ (NSURLProtectionSpace*)defaultProtectionSpace;

- (void)authenticateWithVerifierToken:(NSString*)verifierToken;

@end
