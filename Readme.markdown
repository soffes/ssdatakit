# Data Kit

Data Kit aims to do the following:

* Eliminate boilerplate Core Data setup code
* Greatly reduce fetch request boilerplate code
* Make working with remote objects stupid easy
* Make display Core Data objects in a view controller really simple
* Provide some handy utilities

Data Kit is made up of several Core Data subclasses, categories on Core Data objects, and several view controllers.

## What's Included

### DKTManagedObject

* Manages main context, persistent store, etc
* Accessing entity descriptions
* Reflection
* Easy creating and deleting

The main benefit of DKTManagedObject is that it always has a "main context" so you can eliminate a lot of typing if you are working on your main context. Since it has a main context, it makes getting the entity description really easy which makes lots of additional methods really simple.


### DKTRemoteManagedObject

* Easily find or create objects by a remote ID
* Unpack `NSDictionary`'s into your Core Data object's attributes

DKTRemoteManagedObject is designed to unpack NSDictionary objects into its attributes. This is perfect for getting objects from an API and putting them into Core Data.


## Example

This is very simple example of how to use DKTRemoteManagedObject.

Post.m

``` objective-c
- (void)unpackDictionary:(NSDictionary *)dictionary {
  [super unpackDictionary:dictionary];
  self.title = dictionary[@"title"];
}
```

Now you can create and find posts easily.

``` objective-c
Post *post = [Post objectWithDictionary:@{@"id": @(1), @"title": @"Hello World"}];
Post *anotherPost = [Post objectWithRemoteID:@(1)];
NSLog(@"Equal: %i", [post isEqual:anotherPost]); // Equal: 1
```

## Installation

If you're using [CocoaPods](http://cocoapods.org), add the following to your Podfile:

``` ruby
pod 'DataKit'
```

If you want to add Data Kit to your project manually, simply add all of the files in the `DataKit` directory and [SAMCategories](https://github.com/soffes/SAMCategories) to your project.
