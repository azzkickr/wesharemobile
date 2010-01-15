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

#import "WSSharePlugin.h"
#import "WSBasePlugin.h"

#import "WSDialog.h"
#import "WSShareDialog.h"
#import "WSSharePluginDialog.h"

#import "WSShareCenter.h"

// Dicitonary keys for typical data values
#define kWSTitleDataDictKey @"title"
#define kWSUrlDataDictKey @"url"
#define kWSMessageDataDictKey @"message"
#define kWSDescriptionDictKey @"description"
#define kWSImageURLDictKey @"imageURL"
#define kWSEMailSubjectDataDictKey @"email.subject"
#define KWSEMailMessageDictKey @"email.message"

/* Twitter Plugin keys */
#define kWSTwitterMessagekey @"twitter.message"

/* Facebook Plugin keys*/
#define kWSFacebookCaptionKey @"facebook.caption"