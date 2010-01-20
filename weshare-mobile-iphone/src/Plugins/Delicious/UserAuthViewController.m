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
 
 
 Author: Reiner Pittinger <reiner.pittinger@neofonie.de>, <DATE: 2009-12-11>
 
 */

#import "UserAuthViewController.h"
#import "WeShareGlobal.h"
#import "WSDeliciousPlugin.h"

@interface UserAuthViewController ()

- (void)oauthVerifierReceived;

@end


@implementation UserAuthViewController

@synthesize userAuthURL, oauthVerifierToken;

- (id)initWithURL:(NSURL *)inURL {
	if (self = [super initWithNibName:@"UserAuthViewController" bundle:nil]) {
		self.userAuthURL = inURL;
	}
	
	return self;
}

- (void)dealloc {	
	[oauthVerifierToken release];
	self.userAuthURL = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[webview setDelegate:self];
	[webview loadRequest:[NSURLRequest requestWithURL: self.userAuthURL]];
	
	// Make the header blink
	titleLabelBlinkView.alpha = 0;
	
	titleLabel.text = WSLocalizedString(@"Login to Yahoo", @"Webpage title of Yahoo login page");
}

- (void)oauthVerifierReceived
{
	WSDeliciousPlugin* plugin = (WSDeliciousPlugin*)[[WSShareCenter sharedCenter] pluginForClass: [WSDeliciousPlugin class]];
	[plugin authenticateWithVerifierToken: oauthVerifierToken];
}

#pragma mark - UIWebView Delegate Methods -

- (void)webViewDidFinishLoad:(UIWebView *)webView
{	
	/*
	 This is a try to automatically detect the verifier code Yahoo presents to the user.
	 
	 It is a highlighted 6-digit-code in a span element.
	 
	 I know, it is awkward, but the alternate approach via Copy & Paste is cumberstone for the user.
	 */
	NSString* verifierCode = [webView stringByEvaluatingJavaScriptFromString: @"document.getElementsByTagName('span')[0].textContent;"];
	ZNLog(@"%@", verifierCode);
	if (verifierCode && ![verifierCode isEqualToString: @"undefined"] && [verifierCode length] == 6) {
		oauthVerifierToken = [verifierCode retain];
		[self oauthVerifierReceived];
	}

}

@end
