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
 
 
 Created by Reiner Pittinger on 09.11.09.
 
 */

#import "WeShareDemoViewController.h"
#import "WeShare.h"
#import "UIView+FirstResponderAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation WeShareDemoViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[shareDialog release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(resizeScrollView:)
												 name: UIKeyboardWillShowNotification
											   object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(resizeScrollView:)
												 name: UIKeyboardWillHideNotification
											   object: nil];
		
	[scrollView setContentSize: [contentView bounds].size];
	messageView.layer.borderWidth = 1.0;
	messageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	
	NSMutableArray* items = [NSMutableArray arrayWithArray: toolbar.items];
	[items addObject: [WSShareCenter weShareToolbarItemWithTarget: self action: @selector(showDialog)]];
	
	[toolbar setItems: items animated: NO];
}

- (IBAction)showDialog
{
	[[WSShareCenter sharedCenter] shareData: [self shareData]
						 hostViewController: self];
}

- (NSDictionary*)shareData
{
	/*
	 ATTENTION: none of your values may be nil in this case, or you anything after 
	 this value will be ignored (as nil terminates the list of objects and keys).
	 */ 
	return [NSDictionary dictionaryWithObjectsAndKeys: 
			titleField.text, kWSTitleDataDictKey, 
			messageView.text, kWSMessageDataDictKey, 
			messageView.text, KWSEMailMessageDictKey,
			[NSURL URLWithString: urlField.text], kWSUrlDataDictKey, nil];
}

- (IBAction)dismissKeyboard
{
	[[self.view findFirstResonder] resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	UINavigationItem* navItem = [[navBar items] objectAtIndex: 0];
	if (navItem) {
		[navItem setRightBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
																					   target: self
																					   action: @selector(dismissKeyboard)] autorelease]];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	UINavigationItem* navItem = [[navBar items] objectAtIndex: 0];
	if (navItem) {
		[navItem setRightBarButtonItem: nil];
	}
}
																	 
- (void)resizeScrollView:(NSNotification*)aNotification
{
	NSValue* aValue = [[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
	CGPoint keyboardCenterEnd = [(NSValue*)[[aNotification userInfo] objectForKey: UIKeyboardCenterEndUserInfoKey] CGPointValue];
	CGRect keyBoardRect = [aValue CGRectValue];
	
	CGRect newRect = scrollView.frame;
	
	if ([[aNotification name] isEqualToString: UIKeyboardWillShowNotification]) {
		// New size = scrollView size - overlapping keyboard
		
		CGRect keyboardRectEnd = CGRectMake(keyboardCenterEnd.x - keyBoardRect.size.width / 2,
											  keyboardCenterEnd.y - keyBoardRect.size.height / 2,
											  keyBoardRect.size.width, keyBoardRect.size.height);
		
		keyboardRectEnd = [self.view.window convertRect: keyboardRectEnd toView: self.view];
				
		CGRect intersection = CGRectIntersection(newRect, keyboardRectEnd);
		
		distance = intersection.size.height;
		
		newRect.size.height -= distance;
	} else {
		newRect.size.height += distance;
	}
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationCurve: (UIViewAnimationCurve)[[aNotification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey]];
	[UIView setAnimationDuration: [[[aNotification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	scrollView.frame = newRect;
	
	[UIView commitAnimations];
}

@end
