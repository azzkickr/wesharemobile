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
 
 Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 25.11.09.
 
 */

#import "WSSharePluginDialog.h"
#import "WeShareGlobal.h"
#import "WSSharingResultView.h"
#import <QuartzCore/QuartzCore.h>

#define kPluginDialogMargin 16.0
#define kPluginViewMargin 16.0
#define kPluginViewTopMargin 48.0
#define kPluginViewBottomMargin 46.0

#define kSharingResultMessageTopMargin 180

#define kWSSharingResultViewTag 2

/*
 The delay between displaying the sharing result message (success/fail) and automatically dismissing the plugin dialog.
 */
#define kAutoDismissDelay 2

@interface WSSharePluginDialog ()

- (NSArray*)toolbarItemsForSharingResult:(WSSharingResultState)resultState;

@end

@implementation WSSharePluginDialog

@synthesize pluginView, fullscreen, autoDismiss, commitButton;

- (id)init
{
	self = [super init];
	if (self != nil) {		
		// Register for all sharing-results to show the correspondig image
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(displaySharingResultNotification:) name: kWSSharingSuccessfulNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(displaySharingResultNotification:) name: kWSSharingFailedNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(displaySharingResultNotification:) name: kWSSharingCancelledNotification object: nil];		
	}
	return self;
}

- (id)initWithDelegate:(id<WSSharePluginDialogDelegate>)aDelegate
{
	self = [self init];
	if (self != nil) {
		self.delegate = aDelegate;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	self.delegate = nil;
	self.pluginView = nil;
	[commitButton release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	backgroundView.layer.cornerRadius = 10.0;
	
	titleLabel.text = self.title;
	commitButton = [[UIBarButtonItem alloc] initWithTitle: WSLocalizedString(@"Share", @"DO NOT TRANSLATE! Share-Button-Text")
													style: UIBarButtonItemStyleDone
												   target: self
												   action: @selector(commit)];
	
	resultView.errorMessageView.font =[UIFont systemFontOfSize: [UIFont systemFontSize]];
	
	// Configure the toolbar with the default items
	[toolbar setItems: [self toolbarItemsForSharingResult: WSSharingResultStateNone] animated: NO];
	
	titleBar.hidden = self.fullscreen;
	toolbar.hidden = self.fullscreen;
}

- (void)setPluginView:(UIView *)aView
{
	if (pluginView) {
		[pluginView removeFromSuperview];
		[pluginView release];
	}
	if (aView) {
		pluginView = [aView retain];
		pluginView.clipsToBounds = YES;
		pluginView.frame = [self pluginViewBounds];
		[self.view addSubview: pluginView];
	}
}

- (CGRect)pluginViewBounds
{
	CGRect result = CGRectInset(self.view.bounds, kPluginViewMargin, kPluginViewMargin);
	
	if (!self.fullscreen) {
		result.origin.y = kPluginViewTopMargin;
		result.size.height -= kPluginViewBottomMargin + result.origin.y - kPluginViewMargin;
	}
	
	return result;
}

- (void)setFullscreen:(BOOL)aFlag
{
	fullscreen = aFlag;
	
	titleBar.hidden = self.fullscreen;
	toolbar.hidden = self.fullscreen;
}

#pragma mark UI actions

- (IBAction)dismiss
{
	// Resign any first responsers of the pluginview
	[[pluginView findFirstResonder] resignFirstResponder];

	[super dismiss];
}

- (IBAction)dismissAll
{
	[self dismiss];
	[[WSShareCenter sharedCenter].shareDialog dismiss];
}

- (IBAction)commit
{
	if (self.delegate && [self.delegate respondsToSelector: @selector(didPressCommitInDialog:)]) {
		[(id<WSSharePluginDialogDelegate>)self.delegate didPressCommitInDialog: self];
	}
}

- (void)displaySharingResultNotification:(NSNotification*)aNotification
{
	NSString* notificationName = [aNotification name];
	
	BOOL sharingCancelled = [notificationName isEqualToString: kWSSharingCancelledNotification];
	
	if (!sharingCancelled) {
		UIImage* resultImage;
		NSString* labelText;
		WSSharingResultState resultState;
		id<WSSharePlugin> plugin = [aNotification object];
		
		if ([notificationName isEqualToString: kWSSharingSuccessfulNotification]) {
			resultState = WSSharingResultStateSuceeded;
			resultImage = [UIImage imageNamed: @"ico_ok.png"];
			labelText = WSLocalizedString(@"Sharing success!", @"Message used to display that sharing with a plugin was successfull");
		}
		if ([notificationName isEqualToString: kWSSharingFailedNotification]) {
			resultState = WSSharingResultStateFailed;
			resultImage = [UIImage imageNamed: @"ico_fail.png"];
			labelText = WSLocalizedString(@"Sharing fail!", @"String template used to state that sharing with a plugin failed");
		}
		
		// Optionally customize sharing result message
		if ([plugin respondsToSelector: @selector(messageForSharingResult:)]) {
			labelText = [plugin messageForSharingResult: resultState];
		}
		
		resultView.titleLabel.text = labelText;
		resultView.iconView.image = resultImage;
		
		resultView.errorMessageView.hidden = resultState == WSSharingResultStateSuceeded;
		
		if (resultState == WSSharingResultStateFailed) {
			NSString* errorMessage = [[aNotification userInfo] objectForKey: kWSSharingFailedErrorMessageKey];
			if (!errorMessage) {
				errorMessage = @"";
			} 
			resultView.errorMessageView.text = errorMessage;
		}
		
		// TODO: Move into own method
		// Make the resultView slide in from right		
		CGRect frame = pluginView.frame;
		frame.origin.y = 0;
		frame.origin.x += frame.size.width - CGRectGetMinX(pluginView.frame);
		resultView.frame = frame;
		
		BOOL animateInToolbar = self.fullscreen;
		
		if (animateInToolbar) {
			// Always show the toolbar in result screen, but move it out first
			CGFloat toolbarHeight = toolbar.bounds.size.height;
			UIToolbar* resultViewToolbar = [[[UIToolbar alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(resultView.frame) - toolbarHeight, 
																						CGRectGetWidth(resultView.frame),
																						toolbarHeight)] autorelease];
			resultViewToolbar.tintColor = toolbar.tintColor;
			[resultViewToolbar setItems: [self toolbarItemsForSharingResult: resultState]
							   animated: NO];
			[resultView addSubview: resultViewToolbar];
		}
		
		[pluginView addSubview: resultView];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration: kWSTransitionDuration/1.5];
		
		resultView.transform = CGAffineTransformMakeTranslation(-frame.size.width, 0);
		
		[UIView commitAnimations];
		
		// Update the toolbar
		[toolbar setItems: [self toolbarItemsForSharingResult: resultState] animated: YES];
	}
	
	if (self.autoDismiss) {
		[self performSelector: @selector(dismiss) withObject: nil afterDelay: sharingCancelled == WSSharingResultStateCancelled ? 0.1 : kAutoDismissDelay];
	}
}

- (void)toggleCommitProgressWithMessage:(NSString*)message
{
	UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
	[spinner startAnimating];
		
	[toolbar setItems: [NSArray arrayWithObjects:
						[[[UIBarButtonItem alloc] initWithCustomView: spinner] autorelease],
						[[[UIBarButtonItem alloc] initWithTitle: message
														  style: UIBarButtonItemStylePlain
														 target: nil
														 action: nil] autorelease], nil] animated: YES];
}

#pragma mark Keyboard Toolbar Animation

- (void)animateKeyboardToolbar:(UIToolbar*)theToolbar keyboardNotification:(NSNotification*)aNotification
{
	BOOL keyboardWillShow = [[aNotification name] isEqualToString: UIKeyboardWillShowNotification];
	
	[self.view addSubview: theToolbar];
	
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationCurve: (UIViewAnimationCurve)[[aNotification userInfo] objectForKey: UIKeyboardAnimationCurveUserInfoKey]];
	[UIView setAnimationDuration: [[[aNotification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	
	theToolbar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(theToolbar.bounds) + keyboardRect.size.height * (keyboardWillShow ? -1 : 1));
	[UIView commitAnimations];
}

- (NSArray*)toolbarItemsForSharingResult:(WSSharingResultState)resultState
{
	NSArray* items;
	
	UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
																				target: nil
																				action: nil] autorelease];
	
	switch (resultState) {
		case WSSharingResultStateFailed:
			items = [NSArray arrayWithObjects:
					 [[[UIBarButtonItem alloc] initWithTitle: WSLocalizedString(@"Retry", @"Button-text to retry sharing an item")
													   style: UIBarButtonItemStyleDone
													  target: self
													  action: @selector(retry)] autorelease],
					 spaceItem,
					 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																	target: self
																	action: @selector(dismiss)] autorelease],
					 nil];
			break;
		case WSSharingResultStateSuceeded:
			items = [NSArray arrayWithObjects:
					 [[[UIBarButtonItem alloc] initWithTitle: WSLocalizedString(@"Share again", nil)
													   style: UIBarButtonItemStyleBordered
													  target: self
													  action: @selector(dismiss)] autorelease],
					 spaceItem,
					 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
																	target: self
																	action: @selector(dismissAll)] autorelease],
					 nil];
			break;
		default:
			items = [NSArray arrayWithObjects: spaceItem, commitButton, nil];
			break;
	}
	return items;
}

- (IBAction)retry
{
	[toolbar setItems: [self toolbarItemsForSharingResult: WSSharingResultStateNone] animated: YES];
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: kWSTransitionDuration/1.5];
	[UIView setAnimationDidStopSelector: @selector(dismissResultViewAnimationStopped)];
	resultView.transform = CGAffineTransformIdentity;
	
	[UIView commitAnimations];
}

- (void)dismissResultViewAnimationStopped
{
	[resultView removeFromSuperview];
}

@end
