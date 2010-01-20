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

/*!
 
 @header WSShareCenter
 @abstract    Controller class for WeShare component.
 @discussion  This class serves as main access point for the WeShare sharing framework.
 
 You can get a single instance using the method:
 
 [WSShareCenter sharedCenter];
*/

#import "WeShareGlobal.h"

@class WSShareDialog;

@interface WSShareCenter : NSObject <WSDialogDelegate> {
	
	NSMutableDictionary* pluginRegistry;
	NSMutableDictionary* pluginDisplayNameRegistry;
	
	WSShareDialog* shareDialog;
	
	/*
	 A counter how many of WeShare dialogs are shown.
	 
	 This will probably not exceed 2 (1x WSShareDialog + 1x WSSharePluginDialog)
	 */
	int dialogCount;
}

@property (readonly, retain) NSMutableDictionary* pluginRegistry;
@property (readonly, retain) NSMutableDictionary* pluginDisplayNameRegistry;
@property (nonatomic, retain) WSShareDialog* shareDialog;
@property (readwrite, assign) int dialogCount;

+ (WSShareCenter*) sharedCenter;

/*!
    @function
    @abstract   Adds a plugin to the registry.
*/
- (void)addPlugin:(id<WSSharePlugin>)plugin;

/*!
    @method     
    @abstract   Removes the service from the registry.
    @discussion Removing services usually is not necessary, as you can define which plug-ins to create
 beforehand with your WeShare config file.
 
 On the other hand, you could remove disabled services (like the Email plugin when Email is not configured on the device)
 when applicationDidReceiveMemoryWarning in your app delegate is called.
*/
- (void)removePlugin:(NSString*)pluginDisplayName;

- (id<WSSharePlugin>)pluginForDisplayName:(NSString*)pluginDisplayName;

- (id<WSSharePlugin>)pluginForClass:(Class)pluginClass;

/*!
    @method     
	@abstract Returns a list of all enabled services.
    @discussion Use this method to get a list of display names of all enabled services, e.g. for populating
 the buttons of a UIActionSheet.
 
 Disabled services will not be included.
*/

- (NSArray*)plugins;

- (NSArray*)pluginDisplayNames;

/*!
    @method     
    @abstract   Displays WeShare's share dialog.
    @discussion When calling this method, a dialog is presented where the can select how he wants to share 
 a specific piece of information (e.g. by sending and E-Mail).
 
 The data dictionary should contain values for different use cases, e.g. a text template for sending an
 E-Mail, a meaningful title etc.
 
	@param data		a dictionary of data values to share. Use the keys defined in <tt>WeShare.h</tt>
	@param hostViewController	a <tt>UIViewController</tt> that hosts the dialog
*/
- (void)shareData:(NSDictionary *)data hostViewController:(UIViewController *)hostViewController;

- (void)shareData:(NSDictionary*)data withPluginForName:(NSString*)pluginDisplayName hostViewController:(UIViewController*)hostViewController;

/*!
 @function  
 @abstract   Returns <tt>YES</tt> if the share dialog is currently visible, <tt>NO</tt> otherwise.
 @discussion 
 
 You should not autorotate your interface while any UI-elements of WeShare are shown!
 
 */
- (BOOL)isDialogShown;

// TODO: Implement rescan of available services (e.g. Email) when app resumes

@end

