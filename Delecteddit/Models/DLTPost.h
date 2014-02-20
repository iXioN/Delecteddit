//
//  DLTPost.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 19/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DLTPage;

@interface DLTPost : NSManagedObject

@property (nonatomic, retain) NSNumber * commentsNumber;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * selftext;
@property (nonatomic, retain) NSNumber * isSelf;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) DLTPage *page;

@end
