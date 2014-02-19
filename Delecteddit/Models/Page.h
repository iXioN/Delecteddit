//
//  Page.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 19/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLTPost;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * after;
@property (nonatomic, retain) NSString * befor;
@property (nonatomic, retain) NSSet *postSet;
@end

@interface Page (CoreDataGeneratedAccessors)

- (void)addPostSetObject:(DLTPost *)value;
- (void)removePostSetObject:(DLTPost *)value;
- (void)addPostSet:(NSSet *)values;
- (void)removePostSet:(NSSet *)values;

@end
