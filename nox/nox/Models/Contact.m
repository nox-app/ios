//
//  Contact.m
//  nox
//
//  Created by Justine DiPrete on 8/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize phoneNumbers = m_phoneNumbers;
@synthesize emails = m_emails;
@synthesize firstName = m_firstName;
@synthesize lastName = m_lastName;

- (id)initWithContactRef:(ABRecordRef)a_contactRef
{
    if(self = [super init])
    {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(a_contactRef, kABPersonPhoneProperty);
        if(phoneNumbers != NULL)
        {
            [self setPhoneNumbers:[NSMutableArray arrayWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbers)]];
            CFRelease(phoneNumbers);
        }
        
        ABMultiValueRef emails = ABRecordCopyValue(a_contactRef, kABPersonEmailProperty);
        if(emails != NULL)
        {
            [self setEmails:[NSMutableArray arrayWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emails)]];
            CFRelease(emails);
        }
        
        CFStringRef firstName = ABRecordCopyValue(a_contactRef, kABPersonFirstNameProperty);
        if(firstName != NULL)
        {
            [self setFirstName:(__bridge NSString *)firstName];
            CFRelease(firstName);
        }
        CFStringRef lastName = ABRecordCopyValue(a_contactRef, kABPersonLastNameProperty);
        if(lastName != NULL)
        {
            [self setLastName:(__bridge NSString *)lastName];
            CFRelease(lastName);
        }
    }
    return self;
}

- (void)mergeInfoFromContactRef:(ABRecordRef)a_contactRef
{
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(a_contactRef, kABPersonPhoneProperty);
    if(phoneNumbers != NULL)
    {
        NSArray * phoneNumbersArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbers);
        for(NSString * phoneNumber in phoneNumbersArray)
        {
            if(![m_phoneNumbers containsObject:phoneNumber])
            {
                [m_phoneNumbers addObject:phoneNumber];
            }
        }
        CFRelease(phoneNumbers);
    }
    
    ABMultiValueRef emails = ABRecordCopyValue(a_contactRef, kABPersonEmailProperty);
    if(emails != NULL)
    {
        NSArray * emailsArray = (__bridge NSMutableArray *)ABMultiValueCopyArrayOfAllValues(emails);
        for(NSString * email in emailsArray)
        {
            if(![m_emails containsObject:email])
            {
                [m_emails addObject:email];
            }
        }
        CFRelease(emails);
    }
}

@end
