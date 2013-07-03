//
//  EventViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface EventViewController : UIViewController
{
    Event * m_event;
    
    IBOutlet UILabel * m_eventLabel; //@todo(jdiprete): delete this
}


- (id)initWithEvent:(Event *)a_event;

@end
