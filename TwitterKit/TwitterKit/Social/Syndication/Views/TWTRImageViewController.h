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

#ifndef TWTRImageViewController_h
#define TWTRImageViewController_h

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <UIKit/UIKit.h>
#import "TWTRMediaContainerViewController.h"

@class TWTRTweetMediaEntity;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRImageViewController : UIViewController <TWTRMediaContainerPresentable>

/**
 * Initializes the image viewer
 *
 * @param image the initial image to show
 * @param mediaEntity the media entity which will be loaded
 * @param parentTweetID the tweet ID of the owner of the image
 */
- (instancetype)initWithImage:(nullable UIImage *)image mediaEntity:(TWTRTweetMediaEntity *)mediaEntity parentTweetID:(NSString *)parentTweetID;

@end

NS_ASSUME_NONNULL_END

#endif /* TWTRImageViewController_h */
