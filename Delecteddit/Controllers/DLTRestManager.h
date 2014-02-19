//
//  DLTRestManager.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@interface DLTRestManager : NSObject

+ (NSURL *)getURLSever;
+ (void)setupRestKit;

- (RKObjectManager *) objectManager;
@end
