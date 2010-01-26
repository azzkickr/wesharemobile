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
 
 
 */

// Created by Reiner Pittinger <reiner.pittinger@neofonie.de> on 23.11.09.

#import "WSShareDialog.h"
#import "WeShareGlobal.h"
#import <QuartzCore/QuartzCore.h>

#define kDefaultPluginIconName @"default-plugin-icon.png"

@implementation WSShareDialog

@synthesize shareData, plugins, tableHeader;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.plugins = [[WSShareCenter sharedCenter] plugins];
	}
	return self;
}

- (void)dealloc {
	self.plugins = nil;
	self.shareData = nil;
	
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleLabel.text = @"";
	dialogSubtitle.text = @"";//WSLocalizedString(@"Share with...", @"Subtitle of share dialog");
	
	infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	NSString* aboutPagePath = [[NSBundle mainBundle] pathForResource: @"about-weshare"
															  ofType: @"html"];
	[aboutWebView setDelegate: self];
	[aboutWebView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: aboutPagePath]]];
	
	if (self.title) {
		titleLabel.text = self.title;
	}

	pluginList.dataSource = self;
	pluginList.delegate = self;
	
	// Frame with title of shared item
	
	CGRect defaultFrame = CGRectMake(29, 106, 261, 203);
	
	if (self.tableHeader) {
		pluginList.frame = defaultFrame;
		tableHeaderLabel.text = self.tableHeader;
	} else {
		pluginList.frame = CGRectUnion(defaultFrame, tableHeaderLabel.frame);
		tableHeaderLabel.text = @"";
	}
	
	tableHeaderBackgroundView.hidden = !self.tableHeader;
	tableHeaderLabel.hidden = !self.tableHeader;
}

- (IBAction)toggleInfoView
{
	if (self.modalViewController) {
		[self dismissModalViewControllerAnimated: YES];
	} else {
		[self presentModalViewController: infoViewController animated: YES];
	}
}

- (void)displayPluginDialogWithPlugin:(id<WSSharePlugin>)aPlugin
{
	[aPlugin shareData: self.shareData hostViewController: self];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	// Get the selected plugin
	id<WSSharePlugin> plugin = [self.plugins objectAtIndex: indexPath.row];
	
	[self displayPluginDialogWithPlugin: plugin];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 51;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	if (self.plugins) {
		return [self.plugins count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *CellIdentifier = @"PluginTableCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	id<WSSharePlugin> plugin = [self.plugins objectAtIndex: indexPath.row];
	
	UIImageView* cellBackgroundView;
	UIImage* pluginImage = [UIImage imageNamed: kDefaultPluginIconName];
	
	if ([plugin respondsToSelector: @selector(pluginImage)]) {
		pluginImage = [plugin pluginImage];
	}
	
	BOOL isIcon = YES;
	if ([plugin respondsToSelector: @selector(isPluginImageIcon)]) {
		isIcon = [plugin isPluginImageIcon];
	}
	
	if (isIcon) {
		cell.textLabel.text = [plugin displayName];
		cell.imageView.image = pluginImage;
	} else {
		// Use image as table cell background
		if (!cell.backgroundView) {
			cellBackgroundView = [[[UIImageView alloc] init] autorelease];
			cellBackgroundView.backgroundColor = [UIColor whiteColor];
			cellBackgroundView.contentMode = UIViewContentModeCenter;
			cell.backgroundView = cellBackgroundView;
		}
		cellBackgroundView.image = pluginImage;
	}
	
	cell.textLabel.font = [UIFont boldSystemFontOfSize: 17.0];
	
	return cell;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ([[request URL] isFileURL]) {
		return YES;
	} else {
		// Open any links in the "About WeShare" in Safari
		[[UIApplication sharedApplication] openURL: [request URL]];
		return NO;
	}
}

@end
