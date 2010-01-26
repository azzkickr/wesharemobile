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

// Created by Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-09-28>

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
