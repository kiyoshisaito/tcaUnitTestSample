import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
struct FizzBuzzFeature {
    @ObservableState
    struct State: Equatable {
        var isVisibleFizz = false
        var isVisibleBuzz = false
        var elseValue: String = ""
    }
    
    enum Action {
        case fizzBuzzButtonTapped(value: Int)
        case updateStateByFizzBuzzResult(result: FizzBuzzResult)
        case updateStateByFizzBuzzResult2(result: FizzBuzzResult2)
    }
    
    @Dependency(\.fizzBuzzRepository) private var fizzBuzzRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fizzBuzzButtonTapped(let value):
                switch value {
                case (let value) where canDivide3And5(value):
                    state.isVisibleFizz = true
                    state.isVisibleBuzz = true
                    state.elseValue = ""
                    break
                case (let value) where canDivide3(value):
                    state.isVisibleFizz = true
                    state.isVisibleBuzz = false
                    state.elseValue = ""
                    break
                case (let value) where canDivide5(value):
                    state.isVisibleFizz = false
                    state.isVisibleBuzz = true
                    state.elseValue = ""
                    break
                default:
                    state.isVisibleFizz = false
                    state.isVisibleBuzz = false
                    return .run { send in
                        let result = await fizzBuzzRepository.fetch1()
                        debugPrint("result is \(result)")
                        await send(.updateStateByFizzBuzzResult(result: result))
                    }
                }
                return .none
                
            case .updateStateByFizzBuzzResult(let result):
                switch result.type {
                case "A":
                    state.elseValue = "AA"
                    debugPrint("type is A, state.elseValue is \(state.elseValue)")
                    break
                case "B":
                    return .run { send in
                        let result2 = await fizzBuzzRepository.fetch2()
                        await send(.updateStateByFizzBuzzResult2(result: result2))
                    }
                default:
                    state.elseValue = "CC"
                    break
                }
                return .none
                
            case .updateStateByFizzBuzzResult2(let result2):
                switch result2.type {
                case "X":
                    state.elseValue = "XX"
                    break
                case "Y":
                    state.elseValue = "YY"
                    break
                default:
                    state.elseValue = "BB"
                    break
                }
                return .none
            }
        }
    }
    
    private func canDivide3(_ value: Int) -> Bool {
        return value % 3 == 0
    }
    
    private func canDivide5(_ value: Int) -> Bool {
        return value % 5 == 0
    }
    
    private func canDivide3And5(_ value: Int) -> Bool {
        return value % 3 == 0 && value % 5 == 0
    }
}

struct FizzBuzzResult {
    let type: String
}

struct FizzBuzzResult2 {
    let type: String
}

struct FizzBuzzRepository {
    var fetch1: () async -> FizzBuzzResult
    var fetch2: () async -> FizzBuzzResult2
}

extension DependencyValues {
    var fizzBuzzRepository: FizzBuzzRepository {
        get { self[FizzBuzzRepository.self] }
        set { self[FizzBuzzRepository.self] = newValue }
    }
}

extension FizzBuzzRepository: DependencyKey {
    public static var liveValue: FizzBuzzRepository = Self(
        fetch1: {
            return FizzBuzzResult(type: "A")
        },
        fetch2: {
            return FizzBuzzResult2(type: "XX")
        }
    )
}
