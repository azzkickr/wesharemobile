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
 
 Created by reiner on 10.12.09.
 
 */

#import "DeliciousURLRequest.h"
#import "WeShareGlobal.h"
#import "MPURLRequestParameter.h"
#import "MPOAuthSignatureParameter.h"

#define kAuthorizationHeaderField @"Authorization"

@interface DeliciousURLRequest ()
@property (nonatomic, readwrite, retain) NSURLRequest *urlRequest;
@end

@implementation DeliciousURLRequest

@dynamic urlRequest;

/*
 We want all the oauth parameters (including the signature) in the HTTP-Header-Fields, and not in the URL.
 
 This is the reason for this class.
 */
- (NSURLRequest  *)urlRequestSignedWithSecret:(NSString *)inSecret usingMethod:(NSString *)inScheme {
	[self.parameters sortUsingSelector:@selector(compare:)];
	
	NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc] init];
	
	NSMutableArray* serviceParams = [[NSMutableArray alloc] init];

	/*
	 Copy OAuth parameters to the HTTP header fields (except the xoauth_yahoo_guid),
	 and filter out non-oauth-params	 
	 */
	[aRequest setValue: @"OAuth realm=\"yahooapis.com\"" forHTTPHeaderField: kAuthorizationHeaderField];
	for (MPURLRequestParameter* parameter in self.parameters) {
		if ([parameter.name rangeOfString: @"oauth_"].location != NSNotFound && [parameter.name rangeOfString: @"xoauth_"].location != NSNotFound) {
			[aRequest addValue: [NSString stringWithFormat: @"%@=\"%@\"", parameter.name, parameter.value] forHTTPHeaderField: kAuthorizationHeaderField];
		} else {
			[serviceParams addObject: parameter];
		}
	}
	
	// Use ALL parameters for generating the signature
	NSMutableString *parameterString = [[NSMutableString alloc] initWithString:[MPURLRequestParameter parameterStringForParameters: self.parameters]];
	MPOAuthSignatureParameter *signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:parameterString andSecret:inSecret forRequest:self usingMethod:inScheme];
	
	// Set the autorization field
	[aRequest addValue: [NSString stringWithFormat: @"%@=\"%@\"", signatureParameter.name, signatureParameter.value] forHTTPHeaderField: kAuthorizationHeaderField];
	
	ZNLog(@"%@", [aRequest valueForHTTPHeaderField: kAuthorizationHeaderField]);
	
	// Overwrite the old parameterString a string containing only the service parameters
	[parameterString release];
	parameterString = [[NSMutableString alloc] initWithString: [MPURLRequestParameter parameterStringForParameters: serviceParams]];
	
	[aRequest setHTTPMethod: self.HTTPMethod];
	
	if ([[self HTTPMethod] isEqualToString:@"GET"] && [self.parameters count]) {
		NSString *urlString = [NSString stringWithFormat:@"%@?%@", [self.url absoluteString], parameterString];
		MPLog( @"urlString - %@", urlString);
		
		[aRequest setURL:[NSURL URLWithString: urlString]];
	} else if ([[self HTTPMethod] isEqualToString:@"POST"]) {
		NSData *postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
		MPLog(@"urlString - %@", self.url);
		MPLog(@"postDataString - %@", parameterString);
		
		[aRequest setURL:self.url];
		[aRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
		[aRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[aRequest setHTTPBody:postData];
	}
	
	[parameterString release];
	[signatureParameter release];
	[serviceParams release];
	
	self.urlRequest = aRequest;
	[aRequest release];
	
	return aRequest;
}

@end
