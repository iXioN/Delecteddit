//
//  DLTRestManager.m
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import "DLTRestManager.h"
@interface DLTRestManager()

@end
@implementation DLTRestManager

+ (NSURL *)getURLSever{
        return [NSURL URLWithString:@"http://www.reddit.com/"];
}

    
+ (void)setupRestKit {
    // Initialize RestKit
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[DLTRestManager getURLSever]];
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    /**
     Complete Core Data stack initialization
     */
    if (!managedObjectStore.persistentStoreCoordinator){
        [managedObjectStore createPersistentStoreCoordinator];
        NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Delecteddit.sqlite"];
        NSError *error;
        NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
        
        // Create the managed object contexts
        [managedObjectStore createManagedObjectContexts];
        
        // Configure a managed object cache to ensure we do not create duplicate objects
        managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
        [managedObjectStore.mainQueueManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        
    }
}

/* Reddit posts Object Manager */
-(RKEntityMapping *)postEntityMapping {
    RKObjectManager *sharedManager = [RKObjectManager sharedManager];
    RKEntityMapping *posttMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:sharedManager.managedObjectStore];
    posttMapping.identificationAttributes = @[ @"identifier" ];
    
    [posttMapping addAttributeMappingsFromDictionary:@{
                                                         @"data.id": @"identifier",
                                                         @"data.num_comments" : @"commentsNumber",
                                                         @"data.thumbnail" : @"thumbnailURL",
                                                         @"data.created" : @"createdDate",
                                                         @"data.score" : @"score",
                                                         @"data.title" : @"title",

                                                         }];
        return posttMapping;
}

-(RKEntityMapping *)pageEntityMapping {
    RKObjectManager *sharedManager = [RKObjectManager sharedManager];
    RKEntityMapping *pageMapping = [RKEntityMapping mappingForEntityForName:@"Page" inManagedObjectStore:sharedManager.managedObjectStore];
//    pageMapping.identificationAttributes = @[ @"identifier" ];
    
    [pageMapping addAttributeMappingsFromDictionary:@{
                                                       @"after": @"after",
                                                       @"befor" : @"befor",
                                                    }
     ];
    RKRelationshipMapping *relationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"children" toKeyPath:@"postSet" withMapping:[self postEntityMapping]];
    [pageMapping addPropertyMapping:relationshipMapping];
    return pageMapping;
}



-(RKResponseDescriptor *)postResponseDescriptor {
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self pageEntityMapping]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@"data"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (RKObjectManager *) objectManager {
    RKObjectManager *sharedManager = [RKObjectManager sharedManager];
    // Register our mappings with the provider
    [sharedManager addResponseDescriptor:[self postResponseDescriptor]];
    return sharedManager;
}

@end
