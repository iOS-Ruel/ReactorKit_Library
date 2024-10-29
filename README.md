# ReactorKit_Library


ReactorKit 공식문서 : https://github.com/ReactorKit/ReactorKit

# RactorKit🤔?

채용공고를 보다보면 ReactorKit에 대한 조건이 많은 것을 보게 되었다.

최근 아키텍쳐에 관심을 갖고 있었기 때문에 ReactorKit에 대하여 한번 알아보고자 한다!

---

## ReactorKit이란?

공식 문서에 따르면

<aside>
💡

ReactorKit은 반응형이고 단방향적인 흐름을 지향하는 아키텍쳐를 위한 프레임워크이다.

</aside>

라고 설명을 하고 있다

또한, ReactorKit은 Flux와 반응형 프로그래밍을 결합한 프레임워크이고, 사용자 동작과 뷰 상태는 각각의 레이어로 Observable 스트림을 통해 전달된다.

이러한 스트림은 단방향으로 흐르며, View는 오직 Action만 방출할 수 있고, Reactor는 오직 State만 방출할 수 있다. ‘

라고 설명을 한다.

여기서 마지막에서 말하는 

**단방향으로 흐르며 View는 Action을 방출하고 Reactor는 State를 방출한다.**  

가 가장 핵심이 되는 말 같으니 기억해두록 하자

[CounterApp](https://www.notion.so/CounterApp-12e00e718f9d80608ea4f1924946c8a4?pvs=21)

앞서 나온 말과 같이 그림을 보면 단방향으로 흐름을 가져가는 것을 확인할 수 있다.

### **ReactorKit의 특징?**

- 기존 MVVM 아키텍쳐 패턴에는 특정 정형화된 템플릿이 없어 개발자들마다 이해하는 사항이 다른 불편함이 존재하였는데 **ReactorKit은 규칙을 두어 MVVM의 형태를 정형화하게 템플릿화**해서 사용할 수 있음

- Rx와 MVVM을 사용하면서 다양한 Observable 변수가 생길때 변수의 상태와 액션의 의도 및 구분이 어려운점을 ReactorKit이 해결

- **비지니스 로직을 분리**함으로 테스트에 용이 (뷰에는 비지니스 로직이 없음)

- 부분적인 아키텍쳐를 따라도됨 (전체가 다 해당 아키텍쳐 패턴을 따르지 않아도됨)

- 간결한 코드를 통해 단순하게 구현하고 확장이 가능

출처: https://green1229.tistory.com/142

### ReactorKit의 구성요소

1. **View**
- View는 사용자의 입력을 받아 Action에 전달
- State를 받아 View는 화면 바인딩
- View 프로토콜을 따르며 Reactor를 주입하여 사용
- **View에는 비지니스 로직이 없음!**

```swift
class ProfileViewController: UIViewController, View {
  var disposeBag = DisposeBag()
}

profileViewController.reactor = UserViewReactor() // Reactor 주입
```

```swift
func bind(reactor: ProfileViewReactor) {
  // action (View -> Reactor)
  refreshButton.rx.tap.map { Reactor.Action.refresh }
    .bind(to: reactor.action)
    .disposed(by: self.disposeBag)

  // state (Reactor -> View)
  reactor.state.map { $0.isFollowing }
    .bind(to: followButton.rx.isSelected)
    .disposed(by: self.disposeBag)
}
```

스토리보드도 지원한다

```swift
let viewController = MyViewController()
viewController.reactor = MyViewReactor() // `bind(reactor:)` 는 즉시 실행되지 않는다.

class MyViewController: UIViewController, StoryboardView {
  func bind(reactor: MyViewReactor) {
    // 뷰가 로드된 이후 (viewDidLoad) 호출 되어 실행된다.
  }
}
```

1. **Reactor**
- View의 상태를 관리함
- 큰 역할은 View에서 비지니스로직을 분리하는 것
- Reactor는 View에 종속되지 않기 때문에 테스트가 용이함
- 모든 View에는 Reactor가 존재함 즉 1:1 임
- Reactor는 Reactor 프로토콜을 준수하기 때문에 Action, Mutation, State를 정의 해주어야함
- initialState라는 속성도 필요

```swift
class ProfileViewReactor: Reactor {
  // represent user actions
  enum Action {
    case refreshFollowingStatus(Int)
    case follow(Int)
  }

  // represent state changes
  enum Mutation {
    case setFollowing(Bool)
  }

  // represents the current view state
  struct State {
    var isFollowing: Bool = false
  }

  let initialState: State = State()
}
```

![image](https://github.com/user-attachments/assets/4601399e-061c-427d-a472-b662c68db1bf)

- Action: 사용자와의 상호작용
- State: View의 상태
- Mutation: Action과 State의 연결다리로 **muate(), reduce() 메서드를 활용하여 Action과 State스트림으로 변환**시킴

1. mutate()
- mutate()는 Action을 받아 Observable<Mutation>을 생성

```swift
func mutate(action: Action) -> Observable<Mutation>
```

- 모든 비동기 작업이나 API 호출과 같은 부수 효과(side effect)는 mutate()메서드에서 수행됨

```swift
func mutate(action: Action) -> Observable<Mutation> {
  switch action {
  case let .refreshFollowingStatus(userID): // receive an action
    return UserAPI.isFollowing(userID) // create an API stream
      .map { (isFollowing: Bool) -> Mutation in
        return Mutation.setFollowing(isFollowing) // convert to Mutation stream
      }

  case let .follow(userID):
    return UserAPI.follow()
      .map { _ -> Mutation in
        return Mutation.setFollowing(true)
      }
  }
}
```

1. reduce()
- reduce()메서드는 이전 상태와 Mutation을 사용하여 **새로운 state를 생성**함.

```swift
func reduce(state: State, mutation: Mutation) -> State
```

- 이 메서드는 순수 함수로, 새로운 stete를 동기적으로 반환해야함. 이 함수에서는 부수효과(side effect)를 발생시키면 안됨
1. transform()
- transform()은 각각의 스트림을 변환(세가지 함수가 있음)

```swift
func transform(action: Observable<Action>) -> Observable<Action>
func transform(mutation: Observable<Mutation>) -> Observable<Mutation>
func transform(state: Observable<State>) -> Observable<State>
```

---





