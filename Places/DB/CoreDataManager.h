#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

+ (CoreDataManager *)shared;

@property (nonatomic, readonly, retain) NSArray		*registredContexts;
@property (nonatomic, readonly) NSOperationQueue	*managerOperationQueue;

@property (readonly, strong, nonatomic) NSManagedObjectContext				*managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel					*managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

- (id)objectForEntityName:(NSString *)entityName withIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext *)context;

- (void)updateObjectsForEntityName:(NSString *)entityName withPropertyLists:(NSArray *)propertyLists andKeyForIdentifier:(NSString *)key;

- (void)removeDataOlderThanDate:(NSDate *)date;

- (NSManagedObjectContext *)context;

- (void)saveContext:(NSManagedObjectContext *)context;

- (void)registerContext:(NSManagedObjectContext *)context;

- (void)removeContext:(NSManagedObjectContext *)context;

@end