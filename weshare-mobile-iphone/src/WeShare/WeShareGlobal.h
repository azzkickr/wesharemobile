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

#define kWSTransitionDuration 0.3

#define kWSSharingSuccessfulNotification @"WSSharingSuccessfulNotification"
#define kWSSharingFailedNotification @"WSSharingFailedNotification"
#define kWSSharingCancelledNotification @"WSSharingCancelledNotification"

#define kWSSharingFailedErrorMessageKey @"WSSharingFailedErrorMessage"


#define WSLocalizedString(theString, comment) NSLocalizedStringFromTable(theString, @"WeShare", comment)
