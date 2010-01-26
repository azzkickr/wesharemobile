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

// Created by reiner on 19.11.09.

#import "WeShareGlobal.h"
#import "WSPluginViewController.h"

@class WSDeliciousPlugin, UserAuthViewController;

@interface WSDeliciousPluginViewController : WSPluginViewController <WSSharePluginDialogDelegate> {
	
	WSDeliciousPlugin* plugin;
	
	IBOutlet UITextField* titleField;
	IBOutlet UITextField* urlField;
	
	IBOutlet UISwitch* useOAuthSwitch;
	IBOutlet UITextView* oAuthInfoView;
	
	IBOutlet UIView* credentialsContainerView;
	
	IBOutlet UITextField* usernameField;
	IBOutlet UITextField* passwordField;
	IBOutlet UISwitch* rememberCredentialsSwitch;
	
	// View controller displaying a website to login (e.g. Yahoo)
	UserAuthViewController* userAuthViewController;
	NSURL* userAuthURL;
	BOOL userAuthViewShown;
	
	/* Label references for easier i18n */
	IBOutlet UILabel* titleLabel;
	IBOutlet UILabel* urlLabel;
	IBOutlet UILabel* oauthSwitchLabel;
	IBOutlet UILabel* accountDataLabel;
	IBOutlet UILabel* usernameLabel;
	IBOutlet UILabel* passwordLabel;
	IBOutlet UILabel* rememberLabel;
	
	BOOL inputsValid;
}

@property (nonatomic, retain) WSDeliciousPlugin* plugin;
@property (nonatomic, retain) NSURL* userAuthURL;
@property (nonatomic, readonly) BOOL userAuthViewShown;
@property (nonatomic, readonly) BOOL inputsValid;

- (id)initWithPlugin:(WSDeliciousPlugin*)aPlugin;

- (IBAction)updateLoginMethod;

- (IBAction)rememberCredentialsToggled;
- (IBAction)clearCredentials;

- (void)presentUserAuthViewController;
- (void)dismissUserAuthViewController;

@end
