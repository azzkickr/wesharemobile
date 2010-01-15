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

#import "WSBasePlugin.h"

@implementation WSBasePlugin

@synthesize displayName, config, enabled, dataDict, hostViewController;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.enabled = YES;
	}
	return self;
}

- (id)initWithConfig:(NSDictionary*)configDict
{
	self = [super init];
	if (self != nil) {
		self.enabled = YES;
		self.config = configDict;
		self.displayName = [configDict valueForKey: @"displayName"];
	}
	return self;
}

- (void)dealloc
{
	self.displayName = nil;
	self.config = nil;
	self.dataDict = nil;
	self.hostViewController = nil;
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController
{
	NSLog(@"This method must be implemented by your subclass!");
}

- (UIImage*)pluginImage
{
	NSString* imageName = [self.config objectForKey: @"iconImageName"];
	if (!imageName) {
		imageName = @"defaultPluginImage.png";
	}
	return [UIImage imageNamed: imageName];
}

- (BOOL)isPluginImageIcon
{
	return YES;
}

- (int)position
{
	int result = INT_MAX;
	id pos = [self.config objectForKey: @"position"];
	if (pos) {
		result = [pos intValue];
	}
	return result;
}

- (int)compare:(id)otherObject
{
	int result = NSOrderedDescending;
	if ([otherObject respondsToSelector: @selector(position)]) {
		int otherPosition = (int)[otherObject performSelector: @selector(position)];
		result = [[NSNumber numberWithInt: [self position]] compare: [NSNumber numberWithInt: otherPosition]];
	}
	return result;
}

@end