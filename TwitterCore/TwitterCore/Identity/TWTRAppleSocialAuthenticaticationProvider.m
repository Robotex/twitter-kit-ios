/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#if !TARGET_OS_TV

#import "TWTRAppleSocialAuthenticaticationProvider.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "TWTRAPIServiceConfig.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRConstants.h"
#import "TWTRSession.h"
#import "TWTRUserAPIClient.h"
#import "TWTRUtils.h"

NSString *const TWTRSocialAppProviderActionSheetCompletionKey = @"TWTRAppleSocialAuthProviderCompletion";

@interface TWTRAppleSocialAuthenticaticationProvider ()

@property (nonatomic, readonly) ACAccountStore *accountStore;
@property (nonatomic) NSArray *accounts;
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, copy, readonly) id<TWTRAPIServiceConfig> apiServiceConfig;
@property (nonatomic, readonly) TWTRUserAPIClient *twitterClient;

@end

@implementation TWTRAppleSocialAuthenticaticationProvider

#pragma mark - init

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig apiServiceConfig:(id<TWTRAPIServiceConfig>)apiServiceConfig
{
    TWTRParameterAssertOrReturnValue(authConfig.consumerKey.length > 0, nil);
    TWTRParameterAssertOrReturnValue(authConfig.consumerSecret.length > 0, nil);

    if (self = [super init]) {
        _authConfig = authConfig;
        _accountStore = [[ACAccountStore alloc] init];
        _apiServiceConfig = apiServiceConfig;
        _twitterClient = [[TWTRUserAPIClient alloc] initWithAuthConfig:authConfig authToken:nil authTokenSecret:nil];
    }

    return self;
}

- (void)authenticateWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);

    [self requestAccessForTwitterAccountsWithCompletion:^(BOOL granted, NSError *error) {
        if (!granted) {
            NSError *permissionDeniedError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeDenied userInfo:@{ NSLocalizedDescriptionKey: @"User denied access to system accounts.", NSLocalizedRecoverySuggestionErrorKey: @"Give this user access to the System Twitter account." }];
            completion(nil, permissionDeniedError);
        } else {
            self.accounts = [self getTwitterAccounts];
            if ([self.accounts count] == 0) {  // No accounts, error
                NSError *noAccountsError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeNoAccounts userInfo:@{ NSLocalizedDescriptionKey: @"User allowed permission to system accounts but there were none set up." }];
                completion(nil, noAccountsError);
                return;
            } else if ([self.accounts count] > 1) {  // Multiple accounts, pick one
                [self showActionSheetWithCompletion:completion];
            } else {  // Only one account, use it
                dispatch_async(dispatch_get_main_queue(), ^{
                    ACAccount *account = [self.accounts firstObject];
                    [self getAuthTokenWithAccount:account completion:completion];
                });
            }
        }
    }];
}

#pragma mark - Accounts framework

/**
 *  Request access to the system Twitter accounts.
 *
 *  @param completion Completion block to be called once the user has selected to allow/deny permission. Will be called on the main thread.
 */
- (void)requestAccessForTwitterAccountsWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    ACAccountType *twitterAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterAccount options:nil completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(granted, error);
            }
        });
    }];
}

- (NSArray *)getTwitterAccounts
{
    ACAccountType *twitterAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    return [self.accountStore accountsWithAccountType:twitterAccount];
}

- (void)performTwitterRequestWithURL:(NSURL *)url parameters:(NSDictionary *)params account:(ACAccount *)account completion:(SLRequestHandler)completion
{
    if (!account) {
        NSLog(@"Attempting to authorize invalid account via SLRequest");
    }
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
    request.account = account;
    [request performRequestWithHandler:completion];
}

#pragma mark - reverse OAuth

// get the temporary oauth token
- (void)getAuthTokenWithAccount:(ACAccount *)account completion:(TWTRAuthenticationProviderCompletion)completion
{
    NSError *parameterError;
    TWTRParameterAssertSettingError(account, &parameterError);
    if (parameterError && completion) {
        completion(nil, parameterError);
        return;
    }
    TWTRParameterAssertOrReturn(completion);

    NSDictionary *parameters = @{ @"x_auth_mode": @"reverse_auth" };
    NSURL *postURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRTwitterRequestTokenPath);
    NSURLRequest *request = [self.twitterClient URLRequestWithMethod:@"POST" URLString:postURL.absoluteString parameters:parameters];

    [self.twitterClient sendAsynchronousRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"[TwitterKit] Error attempting to obtain temporary auth token.");
            completion(nil, connectionError);
            return;
        }
        NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (authToken == nil) {
            NSError *reverseAuthError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeReverseAuthFailed userInfo:@{ NSLocalizedDescriptionKey: @"Reverse auth failed." }];
            NSLog(@"[TwitterKit] Error performing reverse auth.");
            completion(nil, reverseAuthError);
            return;
        }
        [self getAuthTokenWithAccount:account withAuthToken:authToken completion:completion];
    }];
}

// do the reverse oauth
- (void)getAuthTokenWithAccount:(ACAccount *)account withAuthToken:(NSString *)authToken completion:(TWTRAuthenticationProviderCompletion)completion
{
    NSError *parameterError;
    TWTRParameterAssertSettingError(account, &parameterError);
    TWTRParameterAssertSettingError(authToken, &parameterError);
    if (parameterError && completion) {
        completion(nil, parameterError);
        return;
    }
    TWTRParameterAssertOrReturn(completion);

    NSURL *accessTokenURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRTwitterAccessTokenPath);
    NSString *consumerKey = self.authConfig.consumerKey;
    NSDictionary *parameters = @{ @"x_reverse_auth_parameters": authToken, @"x_reverse_auth_target": consumerKey };

    [self performTwitterRequestWithURL:accessTokenURL parameters:parameters account:account completion:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (error.code == NSURLErrorUserCancelledAuthentication) {
                /// The user's credentials are no longer valid, prompt them to renew
                ACAccountStore *store = [[ACAccountStore alloc] init];

                /// We ignore the completion because it always returns ACAccountCredentialRenewResultRejected for Twitter.
                [store renewCredentialsForAccount:account completion:nil];

                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"The system account credentials are no longer valid and will need to be updated in the Settings app.", NSLocalizedRecoverySuggestionErrorKey: @"The user has been prompted to visit the Settings app." };

                NSError *renewError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeSystemAccountCredentialsInvalid userInfo:userInfo];

                NSLog(@"[TwitterKit] User's system account credentials are invalid.");
                completion(nil, renewError);

            } else {
                NSLog(@"[TwitterKit] Error retrieving reverse-auth access token.");
                completion(nil, error);
            }
        } else {
            NSString *recdData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *recdDict = [TWTRUtils dictionaryWithQueryString:recdData];
            completion(recdDict, nil);
        }
    }];
}

#pragma mark - Internal functions

- (void)showActionSheetWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [self alertControllerWithCompletion:completion];
		UIViewController *presentingVC = TWTRUtils.topViewController;
		
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			UIView *view = presentingVC.view;
			alertController.popoverPresentationController.sourceView = view;
			alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0);
			alertController.popoverPresentationController.permittedArrowDirections = 0;
		}

		[presentingVC presentViewController:alertController animated:UIView.areAnimationsEnabled completion:nil];
    });
}

- (UIAlertController *)alertControllerWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	for (ACAccount *account in self.accounts) {
		NSString *title = [NSString stringWithFormat:@"@%@", account.username];
		UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull _action) {
			[self getAuthTokenWithAccount:account completion:completion];
			
		}];
		[alertController addAction:action];
	}
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		completion(nil, [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeCancelled userInfo:@{ NSLocalizedDescriptionKey: @"User cancelled authentication." }]);
	}];
	[alertController addAction:cancelAction];
	
	return alertController;
}

@end
#endif
