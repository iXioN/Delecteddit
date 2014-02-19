//
//  DLTPost.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DLTPost : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * commentsNumber;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * title;

@end
