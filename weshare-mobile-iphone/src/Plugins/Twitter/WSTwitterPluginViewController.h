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
 
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-12-04>
 
 */

#import <UIKit/UIKit.h>
#import "WeShare.h"
#import "WSPluginViewController.h"

@class WSTwitterPlugin;

@interface WSTwitterPluginViewController : WSPluginViewController <UITextViewDelegate> {
	
	NSString* message;
	WSTwitterPlugin* plugin;
	
	UIBarButtonItem* charCountItem;
	
	IBOutlet UITextView* messageView;
	IBOutlet UIView* credentialsContainer;
	IBOutlet UITextField* usernameField;
	IBOutlet UITextField* passwordField;
	
	/* Label references for easier i18n */
	IBOutlet UILabel* usernameLabel;
	IBOutlet UILabel* passwordLabel;
	IBOutlet UILabel* rememberLabel;
	
	BOOL inputsValid;

}

@property (nonatomic, retain) NSString* message;
@property (nonatomic, readonly) BOOL inputsValid;

- (id)initWithPlugin:(WSTwitterPlugin*)aPlugin;
- (void)insertText:(NSString*)theText;

@end
