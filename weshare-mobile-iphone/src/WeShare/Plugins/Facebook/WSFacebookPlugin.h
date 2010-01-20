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
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-09-22>
 
 */

#import "WeShareGlobal.h"
#import "FBConnect/FBConnect.h"

@interface WSFacebookPlugin : WSBasePlugin <FBSessionDelegate, FBDialogDelegate> {
	
	FBSession* facebookSession;
	
	/*
	 These values are set on initialization.
	 */
	NSString* apiKey;
	NSString* appSecret;
	BOOL useSessionProxy;
	NSString* sessionProxyUrl;
	NSString* attachmentTemplate;

}

@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, assign) BOOL useSessionProxy;
@property (nonatomic, retain) NSString *sessionProxyUrl;
@property (nonatomic, retain) NSString* attachmentTemplate;

/*!
    @function
    @abstract   Returns a JSON-string containg data posted to Facebook.
    @discussion 
 
 See http://wiki.developers.facebook.com/index.php/Attachment_%28Streams%29 for more information.
 
    @param      <#(name) (description)#>
    @result     <#(description)#>
*/

- (NSString*)streamDialogAttachment;

@end
