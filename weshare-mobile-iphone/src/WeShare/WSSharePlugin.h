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
 
 
 */

#import "WeShareGlobal.h"

typedef enum  {
	WSSharingResultStateNone,			// An item has not yet been shared
    WSSharingResultStateSuceeded,
    WSSharingResultStateFailed,
	WSSharingResultStateCancelled
} WSSharingResultState;

@protocol WSSharePlugin <NSObject>

@required

/*!
 @method     
 @abstract   <#(brief description)#>
 @discussion <#(comprehensive description)#>
 
 Plug-ins like the WSShareByEMailService need a view controller to push their own "Compose Email" view controller to.
 This is why you should supply a host view controller so that the plugin may work correctly.
 
 */
- (void) shareData:(NSDictionary*)data hostViewController:(UIViewController*)hostViewController;

/*!
 @abstract Must return a string representation of the service that can be used on buttons etc, like "Send as E-Mail" or just "E-Mail".
 */
- (NSString*)displayName;

/*!
 @method     
 @abstract   Set's the displayed name of the plug-in for UI components.
 @discussion The display name of a plug-in (or the "title" of the plug-in") should return text that can be used 
 for UI-components of the application. For example, you could return "Send as E-Mail" for the e-mail plug-in.
 
 @param displayName	a "title"-string for the plug-in
 */

- (void)setDisplayName:(NSString*)displayName;

/*!
 @method     
 @abstract   Returns wether the plug-in is enabled
 @discussion Plug-ins may be disabled if preconditions for the plug-in to work are not fullfilled.
 
 For example, the e-mail plug-in might be disabled because the Mail-App is not configured.
 
 */
- (BOOL)enabled;

@optional


/*!
 @method     
 @abstract   Initializes the Plug-in with the supplied configuration file.
 @discussion A plug-in configuration usually contains properties of the plugin you might want to customize.
 This could be the displayName of a plugin (the text displayed e.g. on a button, like "Send to Twitter").
 
 */
- (id)initWithConfig:(NSDictionary*) config;

/*!
    @method     
    @abstract   Returns an image representing the plugin, e.g. the logo of the service it connects to.
    @discussion You usually specify the path of the image in the <tt>WeShareConfig.plist</tt> file
 and create an instance of <tt>UIImage</tt> with this file.
 
 WeShare assumes that the image returned by this method is a quadratic, small-size icon.
 If you want to use a bigger image to represent the plugin, return NO in <tt>isPluginImageIcon</tt>.
*/
- (UIImage*)pluginImage;

/*!
 @method     
 @abstract   Returns wheter the image returned by <tt>pluginImage</tt> is an icon or a bigger image.
 @discussion When this method returns YES, <tt>WSShareDialog</tt> will use the image as content for the
 table entry instead of a common icon/text-combination.
 */
- (BOOL)isPluginImageIcon;

/*!
    @method     
    @abstract   Returns a custom message for the outcome of sharing some data.
    @discussion The message returned by this method is used by <tt>WSSharePluginDialog</tt> in the confirmation screen
 that is displayed after a WSSharing...Notificaiton was posted.
 
	@param		result: usually one of <tt>WSSharingResultStateSucceeded</tt> or <tt>WSSharingResultStateFailed</tt>.
*/
- (NSString*)messageForSharingResult:(WSSharingResultState)result;

@end