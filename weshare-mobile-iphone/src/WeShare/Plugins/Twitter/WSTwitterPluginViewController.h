/*
 
 WeShare Mobile for iPhone - A library to easily share information on various networks
 
 WeShare Mobile for iPhone - Copyright (C) 2009, 2010 Reiner Pittinger, Initiative neofonie open, 
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
 
 */

// Created by Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-12-04>

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
