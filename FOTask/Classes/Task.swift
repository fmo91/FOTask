//
//  Task.swift
//  TaskFramework
//
//  Created by Fernando Ortiz on 2/7/17.
//  Copyright © 2017 Fernando Martín Ortiz. All rights reserved.
//
import Foundation

public enum TaskError: Error {
    case timeout
}

open class Task<A, B> {
    public init() {}
    
    open func perform(_ input: A, onSuccess: @escaping (B) -> Void, onError: @escaping (Error) -> Void) {
        fatalError()
    }
}

open class BasicTask<A, B>: Task<A, B> {
    
    public typealias ActionType = (A) -> (@escaping (B) -> Void, @escaping (Error) -> Void) -> Void
    
    let action: ActionType
    
    public init(action: @escaping ActionType) {
        self.action = action
    }
    
    override open func perform(_ input: A, onSuccess: @escaping (B) -> Void, onError: @escaping (Error) -> Void) {
        action(input) (
            { (value: B) -> Void in
                onSuccess(value)
            },
            { (error: Error) -> Void in
                onError(error)
            }
        )
    }
}

precedencegroup Additive {
    associativity: left
}

/// Compose
infix operator => : Additive

public func => <A, B, C> (left: Task<A, B>, right: Task<B, C>) -> Task<A, C> {
    return BasicTask { (input: A) in
        return { (onSuccess: @escaping ((C) -> Void), onError: @escaping ((Error) -> Void)) in
            left.perform(input,
                onSuccess: { (firstOutput: B) in
                    right.perform(firstOutput,
                        onSuccess: { (secondOutput: C) in
                            onSuccess(secondOutput)
                        },
                        onError: { (secondError: Error) in
                            onError(secondError)
                        }
                    )
                },
                onError: { (firstError: Error) in
                    onError(firstError)
                }
            )
        }
    }
}

public extension Task {
    public static func parallel<C>(_ tasks: [Task<A, B>], on queue: DispatchQueue = .main, reduceBy reduce: @escaping ([B]) -> C) -> Task<A, C> {
        return BasicTask<A, C> { (input: A) in
            return { (onSuccess: @escaping (C) -> Void, onError: @escaping (Error) -> Void) in
                let group = DispatchGroup()
                
                var results = [B]()
                
                for task in tasks {
                    group.enter()
                    task.perform(input,
                        onSuccess: { (output: B) in
                            results.append(output)
                            group.leave()
                        },
                        onError: { (error: Error) in
                            onError(error)
                            return
                        }
                    )
                }
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    
                    let dispatchGroupResult = group.wait(timeout: .distantFuture)
                    
                    queue.async {
                        switch dispatchGroupResult {
                        case .success:
                            onSuccess(reduce(results))
                        case .timedOut:
                            onError(TaskError.timeout)
                        }
                    }
                }
            }
        }
    }
    
    public func inParallel<U, V>(with task: Task<A, U>, on queue: DispatchQueue = .main, reduceBy reduce: @escaping (B, U) -> V) -> Task<A, V> {
        return BasicTask<A, V> { (input: A) in
            return { (onSuccess: @escaping (V) -> Void, onError: @escaping (Error) -> Void) in
                let group = DispatchGroup()
                
                group.enter()
                group.enter()
                
                var firstValue: B!
                var secondValue: U!
                
                self.perform(input,
                    onSuccess: { (output: B) in
                        firstValue = output
                        group.leave()
                    },
                    onError: { (error: Error) in
                        onError(error)
                        return
                    }
                )
                
                task.perform(input,
                    onSuccess: { (output: U) in
                        secondValue = output
                        group.leave()
                    },
                    onError: { (error: Error) in
                        onError(error)
                        return
                    }
                )
                
                DispatchQueue.global(qos: .background).async {
                    let dispatchGroupResult = group.wait(timeout: .distantFuture)
                    queue.async {
                        switch dispatchGroupResult {
                        case .success:
                            onSuccess(reduce(firstValue, secondValue))
                        case .timedOut:
                            onError(TaskError.timeout)
                        }
                    }
                }
            }
        }
    }
}

public extension Task {
     public func map<C>(_ f: @escaping (B) -> C) -> Task<A, C> {
        return BasicTask<A, C> { (input: A) in
            return { (onSuccess: @escaping (C) -> Void, onError: @escaping (Error) -> Void) in
                self.perform(input,
                    onSuccess: { (output: B) in
                        onSuccess(f(output))
                    },
                    onError: { (error: Error) in
                        onError(error)
                    }
                )
            }
        }
    }
}
