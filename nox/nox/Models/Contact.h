//
//  Contact.h
//  nox
//
//  Created by Justine DiPrete on 8/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <Foundation/Foundation.h>

@interface Contact : NSObject
{
    NSMutableArray * m_phoneNumbers;
    NSMutableArray * m_emails;
    NSString * m_firstName;
    NSString * m_lastName;
}

@property NSMutableArray * phoneNumbers;
@property NSMutableArray * emails;
@property NSString * firstName;
@property NSString * lastName;

- (id)initWithContactRef:(ABRecordRef)a_contactRef;
- (void)mergeInfoFromContactRef:(ABRecordRef)a_contactRef;

@end
