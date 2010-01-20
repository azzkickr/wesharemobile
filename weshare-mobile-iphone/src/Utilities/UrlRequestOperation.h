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
 
 
 
 Based on code by Markus Kirschner.
 
 */

#import "WeShareGlobal.h"

@protocol UrlRequestOperationDelegate;

@interface UrlRequestOperation : NSOperation {
	
	NSString* url;
	NSMutableData* resultData;
	
	BOOL waitingForServer;
	BOOL lastError;
	NSError* error;
	
	NSString * username;
    NSString * password;
	
	id<UrlRequestOperationDelegate> delegate;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) id<UrlRequestOperationDelegate> delegate;
@property (nonatomic, readonly, retain) NSMutableData *resultData;
@property (nonatomic, readonly) NSError* error;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;

- (id)initWithUrl:(NSString*)anUrl delegate:(id<UrlRequestOperationDelegate>)aDelegate;

@end

@protocol UrlRequestOperationDelegate <NSObject>

@optional

- (void)requestOperation:(UrlRequestOperation*)operation didFinishWithData:(NSData*)data;
- (void)requestOperation:(UrlRequestOperation*)operation didFailWithError:(NSError*)error;

@end
