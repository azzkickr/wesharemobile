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

#import "WeShareGlobal.h"
#import "WSTwitterPluginViewController.h"
#import "WSTwitterPlugin.h"
#import <QuartzCore/QuartzCore.h>

#define MESSAGE_MAX_LENGTH 140

@interface WSTwitterPluginViewController ()

- (void)updateCharCount;
- (void)updateCommitButtonState;

@end

@implementation WSTwitterPluginViewController

@synthesize message;

- (id)initWithPlugin:(WSTwitterPlugin*)aPlugin
{
	self = [super init];
	if (self != nil) {
		plugin = [aPlugin retain];
		
		charCountItem = [[UIBarButtonItem alloc] initWithTitle: [NSString stringWithFormat: @"(%d)", MESSAGE_MAX_LENGTH]
														 style: UIBarButtonItemStylePlain
														target: nil
														action: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(scrollToLoginInputs)
													 name: UIKeyboardDidShowNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[charCountItem release];
	[plugin release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	messageView.text = self.message;
	
	messageView.layer.borderWidth = 1;
	messageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	
	usernameField.text = [plugin username];
	passwordField.text = [plugin password];
	
	usernameLabel.text = WSLocalizedString(@"Username", nil);
	passwordLabel.text = WSLocalizedString(@"Password", nil);
	rememberLabel.text = WSLocalizedString(@"Remember", nil);
}

- (void)setMessage:(NSString *)theMessage
{
	if (theMessage) {
		if ([theMessage length] > MESSAGE_MAX_LENGTH) {
			theMessage = [theMessage substringToIndex: MESSAGE_MAX_LENGTH - 1];
		}
		messageView.text = theMessage;
	} else {
		messageView.text = @"";
	}

	[self updateCharCount];
}

- (NSString*)message
{
	return messageView.text;
}

- (void)updateCommitButtonState
{
	pluginDialog.commitButton.enabled = [self inputsValid];
}

- (BOOL)inputsValid
{
	BOOL result = NO;
	
	UIColor* errorColor = WSErrorColor();
	UIColor* normalColor = [UIColor blackColor];
	
	BOOL usernameOK = ![[plugin username] isEmpty];
	BOOL passwordOK = ![[plugin password] isEmpty];
	BOOL messageOK = [messageView.text length] > 0;
	
	usernameLabel.textColor = usernameOK ? normalColor : errorColor;
	passwordLabel.textColor = passwordOK ? normalColor : errorColor;
	messageView.layer.borderColor = messageOK ? normalColor.CGColor : errorColor.CGColor;
	
	result = messageOK && usernameOK && passwordOK;
	return result;
}

- (void)updateCharCount
{
	charCountItem.title = [NSString stringWithFormat: @"(%d)", MESSAGE_MAX_LENGTH - [messageView.text length]];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[super textFieldDidBeginEditing: textField];
	// Make sure all login data fields are shown
	[scrollView scrollRectToVisible: credentialsContainer.frame animated: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[super textFieldDidEndEditing: textField];
	[textField resignFirstResponder];
	
	// Always set username and password, the plugin takes care if values have actually changed
	[plugin setUsername: usernameField.text password: passwordField.text remember: YES];
	[self updateCommitButtonState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return MESSAGE_MAX_LENGTH >= [messageView.text length] - range.length + [text length];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([messageView.text isEqualToString: WSLocalizedString(@"Enter message", nil)]) {
		messageView.text = @"";
	}
	textView.textColor = [UIColor blackColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	[self updateCommitButtonState];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self updateCharCount];
}

#pragma mark Custom Keyboard Toolbar

- (NSArray*)keyboardToolbarItems
{
	// Get default items
	NSMutableArray* items = [NSMutableArray arrayWithArray: [super keyboardToolbarItems]];
	
	if (plugin.dataDict && [plugin.dataDict objectForKey: kWSUrlDataDictKey]) {
		// Add TinyURL-Button
		[items insertObject: [[[UIBarButtonItem alloc] initWithTitle: @"URL"
															   style: UIBarButtonItemStyleBordered
															  target: plugin
															  action: @selector(insertTinyURL)] autorelease]
					atIndex: 0];
	}
	
	// Add charCount-item
	[items insertObject: charCountItem atIndex: [items count] - 1];
	
	return items;
}

- (void)scrollToLoginInputs
{
	if (activeField) {
		[scrollView scrollRectToVisible: credentialsContainer.frame animated: YES];
	}
}

- (void)insertText:(NSString *)theText
{
	messageView.text = [messageView.text stringByReplacingCharactersInRange: messageView.selectedRange
																 withString: theText];
}

@end
