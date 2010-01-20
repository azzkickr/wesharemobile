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

#import "WSEmailPlugin.h"
#import "WeShareGlobal.h"
#import <MessageUI/MessageUI.h>

@implementation WSEmailPlugin

- (id)initWithConfig:(NSDictionary*)aConfig
{
	if (self == [super initWithConfig: aConfig]) {
		if (![MFMailComposeViewController canSendMail]) {
			// We cannot send mails
			self.enabled = NO;
		}
	}
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}

- (void)shareData:(NSDictionary*)data hostViewController:(UIViewController*)viewController
{	
	self.hostViewController = viewController;
	NSString* subject = [data valueForKey: kWSEMailSubjectDataDictKey];
	NSString* messageBody = [data valueForKey: KWSEMailMessageDictKey];
	
	NSString* smSignature = WSLocalizedString(@"Sent using WeShare", @"WeShare E-Mail signature");
	
	if (!messageBody) {
		messageBody = smSignature;
	} else {
		messageBody = [NSString stringWithFormat: @"%@\n\n%@", messageBody, smSignature];
	}
	
	// Show the In-App E-Mail Dialog
	mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
	
	[mailController setSubject: subject];
	
	BOOL isHTML = [[data objectForKey: @"isHTML"] boolValue];
	[mailController setMessageBody: messageBody isHTML: isHTML];		
	
	pluginDialog = [[WSSharePluginDialog alloc] init];
	
	pluginDialog.fullscreenPluginView = YES;
	pluginDialog.delegate = self;
	pluginDialog.pluginView = mailController.view;
	
	[pluginDialog showInView: viewController.view];
	//[self.hostViewController presentModalViewController: mailController animated: YES];
}

#pragma mark WSSharePluginDialogDelegate

- (void)didDismissDialog:(WSSharePluginDialog*)dialog
{
	[pluginDialog release];
	[mailController release];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	NSString* notificationName;
	switch (result) {
		case MFMailComposeResultSent:
		case MFMailComposeResultSaved:
			notificationName = kWSSharingSuccessfulNotification;
			break;
		case MFMailComposeResultCancelled:
			[[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: self];
			[pluginDialog dismiss];
			return;
		default:
			notificationName = kWSSharingFailedNotification;
			break;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName: notificationName object: self];
}

@end
