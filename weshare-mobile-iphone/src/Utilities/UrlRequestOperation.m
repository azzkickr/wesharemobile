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
 

 
 Based on code by Markus Kirschner.
 
 */
#import "UrlRequestOperation.h"

#define kRequestTimeout 20.0

@implementation UrlRequestOperation

@synthesize url;
@synthesize delegate;
@synthesize resultData;
@synthesize error;
@synthesize username, password;

- (id)initWithUrl:(NSString *)anUrl delegate:(id<UrlRequestOperationDelegate>)aDelegate
{
    if (self = [super init]) {
        [self setUrl: anUrl];
        [self setDelegate: aDelegate];
    }
    return self;
}

- (void)dealloc
{
    [url release];
    [delegate release];
	[error release];
	[resultData release];
	[username release];
    [password release];
	[super dealloc];
}

- (void)main
{
	NSDate* timestamp = [NSDate date];
	ZNLog(@"requesting %@", self.url);
	float timeout = kRequestTimeout;
	
	NSURLRequest* theRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: self.url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: kRequestTimeout];
	
	NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow: timeout];
	NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest: theRequest delegate: self];
	
	if (theConnection) 
	{
		// Create the NSMutableData that will hold
		// the received data
		if (resultData) {
			[resultData release];
		}
		resultData = [[NSMutableData alloc] init];
		
		// NSURLConnection callbacks will be 
		// fired during this loop
		waitingForServer = YES;
		do 
		{
			[[NSRunLoop currentRunLoop] acceptInputForMode:NSDefaultRunLoopMode 
												beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
		} while(waitingForServer && [timeoutDate compare:[NSDate date]] == NSOrderedDescending);	
	}
	
	ZNLog(@"request finished, took %.3f seconds", 	[timestamp timeIntervalSinceNow]*-1);
	
	if (waitingForServer && [resultData length] == 0) {
		ZNLog(@"Timeout!");
		[self connection: theConnection didFailWithError: [NSError errorWithDomain: NSURLErrorDomain
																			  code: NSURLErrorTimedOut
																		  userInfo: [NSDictionary dictionaryWithObject: [theRequest URL]
																												forKey: NSErrorFailingURLStringKey]]];
	}
	
	[theConnection release];
}

#pragma mark NSURLConnection delegate methods

/*
 We currently manage the credentials ourself, as the delicious HTTP API returns 3 different realms.
 */
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)aConnection
{
	if (self.username && self.password) {
		return NO;
	} else {
		return YES;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{	
	BOOL shouldCancel = YES;
	
	id<NSURLAuthenticationChallengeSender> sender = [challenge sender];
	
	// Try to get a credential from the credential store
	NSURLCredential* credential = [challenge proposedCredential];
	
	int previousFailureCount = [challenge previousFailureCount];
	
	if (previousFailureCount < 3) {
		if (credential == nil) {
			// If none found, create own credential
			if (self.username && self.password) {
				if (previousFailureCount == 0) 
				{
					NSURLCredential *newCredential= [NSURLCredential credentialWithUser: self.username
																			   password: self.password
																			persistence: NSURLCredentialPersistenceNone];
					[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
					shouldCancel = NO;
				}
			} else {
				shouldCancel = YES;
			}
		} else {
			[sender useCredential: credential forAuthenticationChallenge: challenge];
			shouldCancel = NO;
		}
	}	

	if (shouldCancel) {
		ZNLog(@"Connection authentication failed! Error - %@", challenge);
		[sender cancelAuthenticationChallenge: challenge];
		waitingForServer = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [resultData appendData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
	ZNLog(@"Connection failed! Error - %@ %@",
          [anError localizedDescription],
          [[anError userInfo] objectForKey: NSErrorFailingURLStringKey]);
	
	lastError = true;
	error = [anError retain];
	
	if ([self.delegate respondsToSelector: @selector(requestOperation:didFailWithError:)]) {
		[self.delegate requestOperation: self didFailWithError: error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	ZNLog(@"Succeeded! Received %d bytes of data", [resultData length]);
	
	lastError = false;
	waitingForServer = NO;
	
	if ([self.delegate respondsToSelector: @selector(requestOperation:didFinishWithData:)]) {
		[self.delegate requestOperation: self didFinishWithData: resultData];
	}
}

@end
