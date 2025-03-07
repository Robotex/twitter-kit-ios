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

#ifndef TWTRSETweetTextView_h
#define TWTRSETweetTextView_h

@import UIKit;

@interface TWTRSETweetTextView : UITextView

/**
 Count of number of lines to display, including the cursor on a new line
 (i.e. a cursor at 0 with no text will report 1 line; a cursor just after a newline will include that empty line)
 */
@property (nonatomic, readonly) NSUInteger numberOfLines;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

#endif /* TWTRSETweetTextView_h */
