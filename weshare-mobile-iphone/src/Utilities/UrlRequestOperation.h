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
