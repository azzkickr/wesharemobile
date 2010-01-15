/*
 
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
 
 Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 23.11.09.
 
 */

#import "WeShareGlobal.h"

@interface WSShareDialog : WSDialog <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate> {
	
	NSArray* plugins;
	
	/*
	 The dictionary with the data to share.
	 */
	NSDictionary* shareData;
	
	IBOutlet UIViewController* infoViewController;
	IBOutlet UIWebView* aboutWebView;
	
	IBOutlet UILabel* dialogSubtitle;
	
	NSString* tableHeader;
	IBOutlet UILabel* tableHeaderLabel;
	IBOutlet UIImageView* tableHeaderBackgroundView;
	
	IBOutlet UITableView* pluginList;
}

@property (nonatomic, retain) NSArray* plugins;
@property (nonatomic, copy) NSDictionary* shareData;
@property (nonatomic, retain) NSString* tableHeader;

/*
 Flips the dialog and displays info about SoMo.
 */
- (IBAction)toggleInfoView;

- (void)displayPluginDialogWithPlugin:(id<WSSharePlugin>)aPlugin;

@end
