//
//  UIPlaceHolderTextView.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property NSString * placeholderText;
@property UIColor * placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
