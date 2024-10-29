//
//  CounterViewReactor.swift
//  Reactor_Counter
//
//  Created by Chung Wussup on 10/29/24.
//

import ReactorKit


class CounterViewReactor: Reactor {
    var initialState: State = State()
    
    
    //사용자 인터렉션
    enum Action {
        case increaseBtnTapped
        case decreaseBtnTapped
    }
    
    //상태변경
    enum Mutation {
        case increaseValue
        case decreaseValue
    }
    
    //상태
    struct State {
        var countNumber: Int = 0
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .decreaseBtnTapped:
            return Observable.concat([
                Observable.just(Mutation.decreaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            ])
        case .increaseBtnTapped:
            return Observable.concat([
                Observable.just(Mutation.increaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .decreaseValue:
            state.countNumber -= 1
        case .increaseValue:
            state.countNumber += 1
        }
        
        return state
    }
    
}
