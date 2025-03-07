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

#ifndef TWTRSELocationMapTableViewHeaderView_h
#define TWTRSELocationMapTableViewHeaderView_h

@import CoreLocation;
@import UIKit;

@interface TWTRSELocationMapTableViewHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Create a view with a map view centered around `coordinates`.
 */
- (instancetype)initWithCenterCoordinates:(CLLocationCoordinate2D)coordinates NS_DESIGNATED_INITIALIZER;

@end

#endif /* TWTRSELocationMapTableViewHeaderView_h */
