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

#ifndef TWTRWebAuthenticationTokenRequestor_h
#define TWTRWebAuthenticationTokenRequestor_h

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <TwitterCore/TWTRAPIServiceConfig.h>

@class TWTRAuthConfig;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRAuthenticationTokenRequestCompletion)(NSString *_Nullable token, NSError *_Nullable error);

@interface TWTRWebAuthenticationTokenRequestor : NSObject

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig serviceConfig:(id<TWTRAPIServiceConfig>)serviceConfig;

- (void)requestAuthenticationToken:(TWTRAuthenticationTokenRequestCompletion)completion;

@end

NS_ASSUME_NONNULL_END

#endif /* TWTRWebAuthenticationTokenRequestor_h */
