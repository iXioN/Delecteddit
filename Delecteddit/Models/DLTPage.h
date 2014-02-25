//
//  DLTPage.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 19/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLTPost;

@interface DLTPage : NSManagedObject

@property (nonatomic, retain) NSString * after;
@property (nonatomic, retain) NSString * befor;
@property (nonatomic, retain) NSSet *postSet;
@property (nonatomic, retain) NSDate * insertDate;
@end

@interface DLTPage (CoreDataGeneratedAccessors)

- (void)addPostSetObject:(DLTPost *)value;
- (void)removePostSetObject:(DLTPost *)value;
- (void)addPostSet:(NSSet *)values;
- (void)removePostSet:(NSSet *)values;

@end
