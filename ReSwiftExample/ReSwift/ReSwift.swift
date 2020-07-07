//
//  ReSwift.swift
//  ReSwiftExample
//
//  Created by Michael Guo on 7/6/20.
//  Copyright © 2020 Michael Guo. All rights reserved.
//

import ReSwift

// MARK: - Action

enum AppAction: Action {
    case warmup
    case doneWarmup
}

// MARK: - State

struct AppState: StateType {
    var needsWarmup = true
}

// MARK: - Middleware

let countMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            
            guard
                let appAction = action as? AppAction,
                let appState = getState()
                else {
                    return next(action)
            }
            
            // perform middleware logic
            print(action)
            
            switch appAction {
            case .warmup:
                if appState.needsWarmup {
                    // extra warm up stuff
                    print("Warmup-ing ...")
                    // done warmup
                    mainStore.dispatch(AppAction.doneWarmup)
                }
            default: ()
            }
            
            // call next middleware
            return next(action)
        }
    }
}

// MARK: - Reducer

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    if let action = action as? AppAction {
        switch action {
        case .doneWarmup:
            state.needsWarmup = false
            print("Done warmup ...")
        default: ()
        }
    }
    
    return state
}

// MARK: - Store

let mainStore = MainStore()

class MainStore {
    private let store = Store(reducer: appReducer, state: nil, middleware: [countMiddleware])
    
    private let dispatchQueue = DispatchQueue(label: "MainStore serial queue")
    private let dispatchMainQueue = DispatchQueue.main
    
    func dispatch(_ action: Action) {
        // Using dispatchQueue or dispatchMainQueue
        // unexpected output:
        /*
         warmup
         Warmup-ing ...
         warmup
         Warmup-ing ...
         warmup
         Warmup-ing ...
         doneWarmup
         Done warmup ...
         doneWarmup
         Done warmup ...
         doneWarmup
         Done warmup ...
         */
        
        // While not using queue
        // expected output:
        /*
         warmup
         Warmup-ing ...
         doneWarmup
         Done warmup ...
         warmup
         warmup
         */
        
        
//        dispatchMainQueue.async { [unowned self] in
            self.store.dispatch(action)
//        }
    }
}
