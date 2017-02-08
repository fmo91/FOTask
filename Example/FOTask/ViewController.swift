//
//  ViewController.swift
//  FOTask
//
//  Created by fmo91 on 02/08/2017.
//  Copyright (c) 2017 fmo91. All rights reserved.
//

import UIKit
import FOTask

extension DispatchQueue {
    func delay(_ seconds: Int, execute work: @escaping () -> Void) {
        let deadlineTime = DispatchTime.now() + .seconds(seconds)
        asyncAfter(deadline: deadlineTime) {
            work()
        }
    }
}

final class GetUserName: Task<Void, String> {
    override func perform(_ input: Void, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        DispatchQueue.main.delay(3) {
            onSuccess("Fernando")
        }
    }
}

final class MakeGreetingForUserName: Task<String, String> {
    override func perform(_ input: String, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        onSuccess("Hello \(input)!")
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getUserName = GetUserName()
        let makeGreetingForUserName = MakeGreetingForUserName()
        
        let getGreetingForUserName = getUserName => makeGreetingForUserName
        
        getGreetingForUserName.perform(Void(),
            onSuccess: { greeting in
                print(greeting)
            },
            onError: { error in
                print("oops...")
            }
        )
        
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
                print("An Error! Wooooooooooow!")
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
