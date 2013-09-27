//
//  TextFieldCell.h
//  nox
//
//  Created by Justine DiPrete on 8/19/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell

@property IBOutlet UITextField * textField;

+ (CGFloat)height;

@end
