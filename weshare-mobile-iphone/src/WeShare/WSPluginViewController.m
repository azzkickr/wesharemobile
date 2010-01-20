/*
 
 WeShare Mobile for iPhone - A library to easily share information on various networks

 WeShare Mobile for iPhone - Copyright (C) 2009, 2010 neofonie Technologieentwicklung 
 und Informationsmanagement GmbH (neofonie), http://open.neofonie.de
 
 neofonie provides this program under a dual license model designed to meet the 
 development and distribution needs of both commercial distributors and open source.
  
 For the use as open source you can redistribute it and/or modify 
 this program under the terms of the GNU General Public License version 3  
 as published by the Free Software Foundation, either of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 You may also purchase a commercial license to use this program as non-GPL.
 Please contact open@neofonie.de for further information and assistance. Purchasing a 
 commercial license means that the GPL does not apply, and a commercial license
 (neofonie Commercial Source Code License Version 1.0, NCSL v1.0) includes the 
 assurances that distributors typically find in commercial distribution agreements.
 
 
 Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 07.12.09.
 
 */

#import "WeShareGlobal.h"
#import "WSPluginViewController.h"


@implementation WSPluginViewController

@synthesize activeField, pluginDialog;

- (id)init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(keyboardWasShown:)
													 name: UIKeyboardDidShowNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(keyboardWasHidden:)
													 name: UIKeyboardDidHideNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(keyboardWillShow:)
													 name: UIKeyboardWillShowNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(keyboardWillHide:)
													 name: UIKeyboardWillHideNotification object:nil];
		showKeyboardToolbar = YES;
		
		// We set the frame of the toolbar later
		keyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 460, 320, 44)];
		
		keyboardToolbar.barStyle = UIBarStyleBlack;
		keyboardToolbar.translucent = YES;
				
		// We add and fill the toolbar when it is first displayed.
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[pluginDialog release];
	
	[keyboardToolbar release];
	activeTextView = nil;
	activeField = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[scrollView setContentSize: contentView.bounds.size];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
	// Hide the keyboard toolbar if visible
	if (!keyboardToolbar.hidden) {
		keyboardToolbar.hidden = YES;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

#pragma mark Scrolling the view

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (keyboardShown)
        return;
	
    NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect keyBoardRect = [aValue CGRectValue];
	
	scrollViewDefaultBounds = scrollView.frame;
	
	CGRect absViewRect = [self.view.window convertRect: scrollView.bounds fromView: self.view];
	
	int viewMarginBottom = 480 - absViewRect.size.height - absViewRect.origin.y;
	
    CGSize keyboardSize = keyBoardRect.size;
	
    // Resize the scroll view
    CGRect viewFrame = [self.view.window convertRect: scrollView.bounds fromView: self.view];
    viewFrame.size.height -= keyboardSize.height - viewMarginBottom;
    scrollView.frame = [self.view.window convertRect: viewFrame toView: self.view];
	
    // Scroll the active text field into view.
    CGRect textFieldRect = [activeField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
	
    keyboardShown = YES;
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification
{
	scrollView.frame = scrollViewDefaultBounds;
    keyboardShown = NO;
	
	// Make shure the keyboard toolbar is hidden and at the bottom of the screen
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
	keyboardToolbar.transform = CGAffineTransformMakeTranslation(0, keyboardRect.size.height + CGRectGetHeight(keyboardToolbar.bounds));
	keyboardToolbar.hidden = YES;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
	if (showKeyboardToolbar && activeTextView) {
		if (self.pluginDialog && ![keyboardToolbar isDescendantOfView: pluginDialog.view]) {
			[pluginDialog.view addSubview: keyboardToolbar];
			[keyboardToolbar setItems: [self keyboardToolbarItems]];
		}
		
		NSValue* aValue = [[aNotification userInfo] objectForKey: UIKeyboardBoundsUserInfoKey];
		CGRect keyboardRect = [aValue CGRectValue];
		
		keyboardToolbar.hidden = NO;		
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationCurve: (UIViewAnimationCurve)[[aNotification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey]];
		[UIView setAnimationDuration: [[[aNotification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
				
		keyboardToolbar.transform = CGAffineTransformMakeTranslation(0, -(keyboardRect.size.height + CGRectGetHeight(keyboardToolbar.bounds)));
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
	if (!keyboardToolbar.hidden) {
		CGRect keyboardRect = [[[aNotification userInfo] objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationCurve: (UIViewAnimationCurve)[[aNotification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey]];
		[UIView setAnimationDuration: [[[aNotification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		
		keyboardToolbar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(keyboardToolbar.bounds) + keyboardRect.size.height);
		[UIView commitAnimations];
	}
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	activeTextView = textView;
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	activeTextView = nil;
}

- (IBAction)dismissKeyboard
{
	[[self.view findFirstResonder] resignFirstResponder];
}

- (NSArray*)keyboardToolbarItems
{
	return [NSArray arrayWithObjects: 
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
														   target: nil
														   action: nil] autorelease],
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
														   target: self
														   action: @selector(dismissKeyboard)] autorelease], nil];
}

@end
