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
#import "FBConnect/FBConnect.h"

@interface WSFacebookPlugin : WSBasePlugin <FBSessionDelegate, FBDialogDelegate> {
	
	FBSession* facebookSession;
	
	/*
	 These values are set on initialization.
	 */
	NSString* apiKey;
	NSString* appSecret;
	BOOL useSessionProxy;
	
	NSURL* sessionProxyURL;

}

@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, assign) BOOL useSessionProxy;
@property (nonatomic, retain) NSURL *sessionProxyURL;

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
