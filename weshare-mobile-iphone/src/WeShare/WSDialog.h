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
 
 Created by Reiner Pittinger on 18.12.09.
 
 */

#import "WeShareGlobal.h"

@protocol WSDialogDelegate;

@interface WSDialog : UIViewController {
	
	IBOutlet UIView* backgroundView;
	
	IBOutlet UILabel* titleLabel;
	IBOutlet UIButton* closeButton;
	
	id<WSDialogDelegate> delegate;
}

@property (nonatomic, retain) id<WSDialogDelegate> delegate;

/*
 Displays the dialog in the given view.
 */
- (void)showInView:(UIView*)hostView;

/*
 Dismisses the dialog.
 */
- (IBAction)dismiss;

- (void)dismissAnimationStopped;

@end

@protocol WSDialogDelegate <NSObject>

@optional

/*
 Informs the delegate that this dialog has been closed.
 */
- (void)didDismissDialog:(WSDialog*)dialog;

@end