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

#ifndef TWTRVideoViewController_Private_h
#define TWTRVideoViewController_Private_h

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import "TWTRVideoPlayerView.h"
#import "TWTRVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRVideoViewController () <TWTRVideoPlayerViewDelegate>

@property (nonatomic, readonly) TWTRTweet *tweet;
@property (nonatomic, readonly) TWTRVideoPlaybackConfiguration *playbackConfiguration;
@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) TWTRVideoPlayerView *playerView;

@end

NS_ASSUME_NONNULL_END

#endif /* TWTRVideoViewController_Private_h */
