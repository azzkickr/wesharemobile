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
 
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-08-11>
 
 */

#import "WeShareGlobal.h"
#import "MGTwitterEngine.h"
#import "UrlRequestOperation.h"

@class WSTwitterPluginViewController;

@interface WSTwitterPlugin : WSBasePlugin <MGTwitterEngineDelegate, WSSharePluginDialogDelegate, UrlRequestOperationDelegate> {
	
	WSSharePluginDialog* pluginDialog;	
	WSTwitterPluginViewController* pluginViewController;
	
	MGTwitterEngine* twitterEngine;
	
	NSOperationQueue* operationQueue;
	
	/*
	 A map of connection-IDs to their role (e.g. "verify_credials"). This helps us determining
	 the failiure/success of requests.
	 */
	NSMutableDictionary* connectionIdentifierMap;
	
	NSURLCredential* credentials;
	/*
	 Set to YES when credentials have been confirmed by twitter.
	 */
	BOOL credentialsValid;
	
	/*
	 The posted message.
	 */
	NSString* message;
	
	/*
	 The tinyURL for the URL to share.
	 */
	NSURL* tinyURL;

}

@property (nonatomic, retain) NSString* message;
@property (nonatomic, retain) NSURLCredential* credentials;
@property (nonatomic, readonly) NSURL* tinyURL;

- (void)postToTwitter:(NSString*)aMessage;

- (void)insertTinyURL;

- (NSString*)username;
- (NSString*)password;
- (void)setUsername:(NSString*)username password:(NSString*)password remember:(BOOL)aFlag;
- (void)clearCredentials;

+ (NSURLProtectionSpace*)defaultProtectionSpace;

@end
