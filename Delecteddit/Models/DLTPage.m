//
//  DLTPage.m
//  Delecteddit
//
//  Created by Antonin Lacombe on 19/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import "DLTPage.h"
#import "DLTPost.h"


@implementation DLTPage

@dynamic after;
@dynamic befor;
@dynamic postSet;

@dynamic insertDate;

-(void)willSave {
    NSDate *now = [NSDate date];
    if (self.insertDate == nil ) {
        self.insertDate = now;
    }
}

@end
