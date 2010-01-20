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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#define USE_ZNLOG 1

#ifdef USE_ZNLOG
	// ZNLog by Tony Arnold for nicer console outputs: see http://tonyarnold.com/code-snippets/znlog/
	#import "ZNLog.h"
#else
	#define ZNLog(s,...) NSLog(s,##__VA_ARGS__)
#endif

#import "WeShare.h"
#import "UIView+FirstResponderAdditions.h"
#import "NSString+EmptyAdditions.h"

#define kWSTransitionDuration 0.3

#define kWSSharingSuccessfulNotification @"WSSharingSuccessfulNotification"
#define kWSSharingFailedNotification @"WSSharingFailedNotification"
#define kWSSharingCancelledNotification @"WSSharingCancelledNotification"

#define kWSSharingFailedErrorMessageKey @"WSSharingFailedErrorMessage"

// Macro for easier i18n
#define WSLocalizedString(theString, comment) NSLocalizedStringFromTable(theString, @"WeShare", comment)

// Color macro for inputs with errors
#define WSErrorColor() [UIColor colorWithRed: 0.875 green: 0.125 blue: 0.05 alpha: 1.0];
