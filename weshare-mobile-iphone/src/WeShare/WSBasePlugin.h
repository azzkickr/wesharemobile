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
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-09-23>
 
 */

#import "WeShareGlobal.h"

@interface WSBasePlugin : NSObject <WSSharePlugin> {
	
	BOOL enabled;
	
	/*!
	 Configuration properties for the service, e.g. "displayName" for the service displayed name of the service (e.g. as label on buttons).	 	 
	 */
	NSDictionary* config;
	
	NSString* displayName;
	
	/*!
	 Use this variable to temporarily save the data that should be shared, e.g. when the sharing-process is interrupted by showing a login screen.
	 */
	NSMutableDictionary* dataDict;
	
	UIViewController* hostViewController;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, retain) NSDictionary* config;
@property (nonatomic, retain) NSMutableDictionary* dataDict;
@property (nonatomic, assign) UIViewController* hostViewController;

- (id)initWithConfig:(NSDictionary*)configDict;

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController;

// TODO: Define interface methods for supported and required dataKeys

@end