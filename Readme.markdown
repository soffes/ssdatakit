# SSDataKit

There is a lot of boilerplate code required to write a Core Data application. This is annoying. In pretty much everything I've written since Core Data came to iOS, I have used the following class.

## What's Included

### SSManagedObject

* Manages main context, persistent store, etc
* Accessing entity descriptions
* Reflection
* Easy creating and deleting

### SSRemoteManagedObject

* Easily find or create objects by a remote ID
* Unpack `NSDictionary`'s into your Core Data object's attributes

## Example

This is very simple example of how to use SSRemoteManagedObject.

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

For a more complete example, see [CheddarKit](https://github.com/nothingmagical/cheddarkit) which is used in [Cheddar for iOS](https://github.com/nothingmagical/cheddar-ios) and [Cheddar for Mac](https://github.com/nothingmagical/cheddar-mac).
