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

#ifndef TWTRCookieStorageUtil_h
#define TWTRCookieStorageUtil_h

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Convenience methods for managing cookies in the given cookie storage.
 */
@interface TWTRCookieStorageUtil : NSObject

+ (NSArray *)cookiesWithDomainSuffix:(NSString *)domainSuffix;
+ (void)clearCookiesWithDomainSuffix:(NSString *)domainSuffix;

@end

NS_ASSUME_NONNULL_END

#endif /* TWTRCookieStorageUtil_h */
