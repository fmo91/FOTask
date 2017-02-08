# FOTask

[![CI Status](http://img.shields.io/travis/fmo91/FOTask.svg?style=flat)](https://travis-ci.org/fmo91/FOTask)
[![Version](https://img.shields.io/cocoapods/v/FOTask.svg?style=flat)](http://cocoapods.org/pods/FOTask)
[![License](https://img.shields.io/cocoapods/l/FOTask.svg?style=flat)](http://cocoapods.org/pods/FOTask)
[![Platform](https://img.shields.io/cocoapods/p/FOTask.svg?style=flat)](http://cocoapods.org/pods/FOTask)

## Introduction

FOTask is a microframework (less than 100 LOCs), with a single objective in mind: **separation of concerns**. 
Every subclass of `Task` executes an action. 

## Example usage

**Suclassing Task:**

```swift
final class GetUserTask<Int, Task> {
	override func perform(_ input: Int, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
		ApiClient("https://somecoolapi.com/users/\(input)", .get,
        	onSuccess: { (json: Any) in
            	onSuccess(User(json: json))
            }, 
            onError: { (error: Error) in
            	onError(error)
            }
        ) 
    }
}
```

**Using Task:**

```swift
let getUserTask = GetUserTask()

getUserTask.perform(3,
	onSuccess: { (user: User) in
    	print(user.name)
    },
    onError: { (error: Error) in
    	print("An error ocurred.")
    }
)
```

**Composing Tasks:**

```swift
let getUserWithIDTask = GetUserTask()
let getPostsFromUserTask = GetPostsFromUserTask()

let getPostsFromUserID = getUserWithIDTask => getPostsFromUserTask

getPostsFromUserID.perform(3,
	onSuccess: { (posts: [Post]) in
    	print(posts.count)
    },
    onError: { (error: Error) in
    	print("An error ocurred.")
    }
)
```

**Parallelize Tasks**

```swift
let getALotOfUserNames = Task.parallel(
    [
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName(),
        GetUserName()
    ],
    reduce: { (userNames: [String]) -> [String] in
        return userNames
    }
)

getALotOfUserNames.perform(Void(),
    onSuccess: { userNames in
        print(userNames)
    },
    onError: { error in
        print("An Error!")
    }
)
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.0 or above.
* Swift 3.0 or above.

## Installation

FOTask is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FOTask"
```

## Coming soon

* More documentation
* More examples
* More functional features?

## Author

fmo91, ortizfernandomartin@gmail.com

## License

FOTask is available under the MIT license. See the LICENSE file for more info.
