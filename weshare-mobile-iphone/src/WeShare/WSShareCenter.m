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

#import "WeShareGlobal.h"
#import <objc/runtime.h>

static WSShareCenter* sharedCenter = nil;

@interface WSShareCenter()

- (void) loadConfig;
	
@end

@implementation WSShareCenter

@synthesize pluginRegistry, pluginDisplayNameRegistry, shareDialog, dialogCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		pluginRegistry = [[NSMutableDictionary alloc] init];
		pluginDisplayNameRegistry = [[NSMutableDictionary alloc] init];		
		[self loadConfig];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(sharingSuccessful:) name: kWSSharingSuccessfulNotification object: nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	self.shareDialog = nil;
	[pluginRegistry release];
	[pluginDisplayNameRegistry release];
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data withPluginForName:(NSString*)pluginDisplayName hostViewController:(UIViewController*)hostViewController
{
	id<WSSharePlugin> plugin = [self pluginForDisplayName: pluginDisplayName];
	if (plugin) {
		[plugin shareData: data hostViewController: hostViewController];
	} else {
		NSLog(@"No plugin found with name %s", pluginDisplayName);
	}
}

- (void)shareData:(NSDictionary *)data hostViewController:(UIViewController *)hostViewController
{
	if (!self.shareDialog) {
		self.shareDialog = [[WSShareDialog alloc] init];
		self.shareDialog.delegate = self;
	}	
	self.shareDialog.shareData = data;
	
	NSString* title = [data objectForKey: kWSTitleDataDictKey];
	if (title) {
		self.shareDialog.tableHeader = [NSString stringWithFormat: @"'%@'", title];
	}
	
	[self.shareDialog showInView: hostViewController.view];
}

// Delegate method: release the dialog after it's been closed
- (void)didDismissDialog:(WSDialog *)dialog
{
	self.shareDialog = nil;
}

- (BOOL)isDialogShown
{
	return self.dialogCount > 0;
}

// ???: Avoid replacing plug-ins when using the same displayName?
- (void)addPlugin:(id<WSSharePlugin>)plugin
{
	NSString* className = [NSString stringWithCString: class_getName([plugin class]) encoding: NSUTF8StringEncoding];
	[pluginDisplayNameRegistry setObject: plugin forKey: plugin.displayName];
	[pluginRegistry setObject: plugin forKey: className];
}

- (void)removePlugin:(NSString*)pluginDisplayName
{
	id plugin = [self pluginForDisplayName: pluginDisplayName];
	[pluginRegistry removeObjectForKey: [NSString stringWithCString: class_getName([plugin class]) encoding: NSUTF8StringEncoding]];
	[pluginDisplayNameRegistry removeObjectForKey: pluginDisplayName];
}

- (id<WSSharePlugin>)pluginForDisplayName:(NSString*)pluginDisplayName
{
	return [pluginRegistry objectForKey: pluginDisplayName];
}

- (id<WSSharePlugin>)pluginForClass:(Class)pluginClass
{
	NSString* className = [NSString stringWithCString: class_getName(pluginClass) encoding: NSUTF8StringEncoding];
	return [pluginRegistry objectForKey: className];
}

- (NSArray*)pluginDisplayNames
{
	NSMutableArray* list = [NSMutableArray arrayWithCapacity: [pluginRegistry count]];
	for (NSString* pluginDisplayName in [pluginRegistry allKeys]) {
		id<WSSharePlugin> plugin = [self pluginForDisplayName: pluginDisplayName];
		if (plugin.enabled) {
			[list addObject: pluginDisplayName];
		}
	}
	return list;
}

- (NSArray*)plugins
{
	return [[pluginRegistry allValues] sortedArrayUsingSelector: @selector(compare:)];
}

- (void)sharingSuccessful:(NSNotification*)aNotification
{
	id sender = [aNotification object];
	if ([sender conformsToProtocol: @protocol(WSSharePlugin)]) {
		id<WSSharePlugin> plugin = sender;
		ZNLog(@"Sharing successful with plugin: %@", [NSString stringWithCString: class_getName([plugin class]) encoding: NSUTF8StringEncoding]);
	}
}

+ (UIBarButtonItem*)weShareToolbarItemWithTarget:(id)aTarget action:(SEL)anAction
{
	UIImage* backgroundImageNormal = [UIImage imageNamed: @"weshare-toolbarIcon-colored.png"];
	UIImage* backgroundImageSelected = [UIImage imageNamed: @"weshare-toolbarIcon-colored-highlighted.png"];
	
	UIButton* button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, backgroundImageNormal.size.width, backgroundImageNormal.size.height)];
	[button setTitle: @"" forState: UIControlStateNormal];
	[button setTitle: @"" forState: UIControlStateSelected];
	[button setTitle: @"" forState: UIControlStateHighlighted];
	[button setBackgroundImage: backgroundImageNormal forState:UIControlStateNormal];
	[button setBackgroundImage:backgroundImageSelected forState: UIControlStateSelected];
	[button setBackgroundImage:backgroundImageSelected forState: UIControlStateHighlighted];
	
	[button addTarget: aTarget action: anAction forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithCustomView: button] autorelease];
	return item;
}

/*!
 @method     
 @abstract   Loads and processes the config file.
 @discussion 
 
 WeShare expects a "WeShareConfig.plist" file in the main bundle, which contains configuration options for each service.
 Each key must be the class-name of the service, and it's value should represent a configuration for the service.
 
 After each services initialization, the service is saved and accessible under it's configuration key (see above).
 */
- (void) loadConfig
{
	// Load Plist
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"WeShareConfig" ofType:@"plist"];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *config = (NSDictionary *)[NSPropertyListSerialization 
											propertyListFromData: plistXML
											mutabilityOption:NSPropertyListMutableContainersAndLeaves
											format: &format errorDescription: &errorDesc];
	if (!config) {
		NSLog(@"Error loading config file: %@", errorDesc);
		[errorDesc release];
	}
	
	// Process config
	
	id<WSSharePlugin> plugin;
	NSDictionary* pluginConfig;
	// Create an instance of each plugin and configure it
	NSDictionary* pluginClassNames = [config valueForKey: @"Plugins"];
	for (NSString* pluginClassName in pluginClassNames) {
		// Try to find a class with the given key
		// Try to instanciate the service
		Class pluginClass = objc_getClass([pluginClassName cStringUsingEncoding: NSUTF8StringEncoding]);
		if (pluginClass) {
			pluginConfig = [pluginClassNames objectForKey: pluginClassName];
			if ([pluginClass instancesRespondToSelector: @selector(initWithConfig:)]) {
				plugin = [[pluginClass alloc] initWithConfig: pluginConfig];
			} else {
				plugin = [[pluginClass alloc] init];
				// Make sure that at least the name is set
				NSString* pluginDisplayName = [pluginConfig valueForKey: @"displayName"];
				if (!pluginDisplayName) {
					pluginDisplayName = pluginClassName;
				}
				[plugin setDisplayName: pluginDisplayName];
			}
			[self addPlugin: plugin];
			[plugin release];
		}
	}
}

#pragma mark Cocoa singleton implementation

+ (WSShareCenter*)sharedCenter
{ 
	@synchronized(self) 
	{ 
		if (sharedCenter == nil) 
		{
			sharedCenter = [[self alloc] init]; 
		}
	} 
	
	return sharedCenter; 
}

+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedCenter == nil) 
		{ 
			sharedCenter = [super allocWithZone:zone]; 
			return sharedCenter; 
		} 
	} 
	
	return nil; 
} 

- (id)copyWithZone:(NSZone *)zone 
{ 
	return self; 
} 

- (id)retain 
{ 
	return self; 
} 

- (NSUInteger)retainCount 
{ 
	return NSUIntegerMax; 
} 

- (void)release 
{
	
} 

- (id)autorelease 
{ 
	return self; 
}

@end
