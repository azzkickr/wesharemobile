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
 
 Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 07.12.09.
 
 */

#import "WeShareGlobal.h"

@interface WSPluginViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
	
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIView* contentView;
	
	UITextField* activeField;
	UITextView* activeTextView;
	
	BOOL keyboardShown;
	BOOL showKeyboardToolbar;
	
	UIToolbar* keyboardToolbar;
	
	CGFloat animatedDistance;
	
	// Bounds of scrollView when the keyboard is not shown
	CGRect scrollViewDefaultBounds;
	
	WSSharePluginDialog* pluginDialog;
}

@property (nonatomic, readonly) UITextField* activeField;
@property (nonatomic, retain) WSSharePluginDialog* pluginDialog;

/*
 Returns an array of <tt>UIBarButtonItems</tt> that should be displayed in a toobar above the keyboard.
 */
- (NSArray*)keyboardToolbarItems;

- (IBAction)dismissKeyboard;

@end
