/*
 
 WeShare for iPhone - a framework to distribute content over various social networks with mobile devices
 
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
 
 Created by Reiner Pittinger on 02.12.09.
 
 */

// Based on the solution by Anthony D at http://stackoverflow.com/questions/949806/is-there-a-way-to-detect-what-uiview-is-currently-visible

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (FindFirstResponder)

- (UIView *)findFirstResonder;

@end
