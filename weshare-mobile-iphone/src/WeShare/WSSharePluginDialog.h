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
 
 
 Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 25.11.09.
 
 */

#import "WeShareGlobal.h"

@class WSSharingResultView;

@protocol WSSharePluginDialogDelegate;

@interface WSSharePluginDialog : WSDialog {
		
	IBOutlet UIView* titleBar;
	
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UILabel* activityMessageLabel;
	
	UIView* pluginView;
	
	/*
	 Sets wheter to automatically dismiss the dialog when sharing has suceeded or failed.
	 */
	BOOL autoDismiss;
	
	/*
	 If set to <tt>YES</tt>, no title- and toolbar are displayed in the plugin dialog.
	 
	 Note that your plugin view <b>must</b> provide buttons to commit and dismiss the dialog!
	 
	 Also in the fullscreen plugins, the result view ("Sharing success/fail") will be displayed 
	 with a toolbar containg the buttons "Share again" and "Done".
	 
	 */
	BOOL fullscreenPluginView;
	
	IBOutlet WSSharingResultView* resultView;
	
	IBOutlet UIToolbar* toolbar;
	UIBarButtonItem* commitButton;
}

@property (nonatomic, retain) UIView* pluginView;

@property (nonatomic, assign) BOOL fullscreenPluginView;

@property (nonatomic, readonly) UIBarButtonItem* commitButton;

@property (nonatomic, assign) BOOL autoDismiss;

- (id)initWithDelegate:(id<WSDialogDelegate>)aDelegate;

/*
 Fired when the "Commit" button at the bottom of the dialog is pressed.
 */
- (IBAction)commit;

/*
 Returns the frame for the plugins view.
 */
- (CGRect)pluginViewBounds;

- (void)displaySharingResultNotification:(NSNotification*)aNotification;

/*!
    @method     
    @abstract   Hides the commit button and displays a progress indicator with the specified message.
    @discussion This method should eventually be called when the plugin send the sharing data to the webservice.
 
 @param message The message to display next to the progress indicator.
*/
- (void)toggleCommitProgressWithMessage:(NSString*)message;

- (void)animateKeyboardToolbar:(UIToolbar*)toolbar keyboardNotification:(NSNotification*)aNotification;

- (IBAction)dismissAll;

@end


#pragma mark -

@protocol WSSharePluginDialogDelegate <WSDialogDelegate>

@optional
- (void)didPressCommitInDialog:(WSSharePluginDialog*)dialog;

@end