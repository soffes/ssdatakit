# SSDataKit

There is a lot of boilerplate code required to write a Core Data application. This is annoying. In pretty much everything I've written since Core Data came to iOS, I have used the following class.

## What's Included

### SSManagedObject

* Manages main context, persistent store, etc
* Accessing entity descriptions
* Reflection
* Easy creating and deleting

### SSManagedObjectContextObserver

* Observe inserted and updated objects in a context

### SSManagedObjectContext

* Adds hooks for SSManagedObjectContextObserver

## Using the Context Observer

You can use `SSManagedObjectContextObserver` to observe when any object is inserted or updated in a context. You can optionally filter this by setting its `entity` property.

Example: (`Photo` is a subclass of `SSManagedObject`)

``` objective-c
SSManagedObjectContextObserver *observer = [[SSManagedObjectContextObserver alloc] init];
observer.entity = [Photo entityDescription];
observer.observationBlock = ^(NSSet *insertedObjects, NSSet *updatedObjects) {
	NSLog(@"Inserted %i photos. Updated %i photos.", insertedObjects.count, updatedObjects.count);
};
[[SSManagedObject mainContext] addObjectObserver:observer];
[observer release];
```

The `observationBlock` will be handed sets of `NSManagedObjectID`s for the inserted and updated objects after a save completes on the observed context. This is handy if you need to do background processing on large sets of changing objects.

If you need to observe deletes, modify an object before save, get objects ordering, etc, you should use the hooks in `NSManagedObject` or use `NSFetchedResultsController`.
