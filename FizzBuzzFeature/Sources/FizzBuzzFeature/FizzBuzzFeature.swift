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
    
    private struct StateObject {
        var isVisibleFizz = false
        var isVisibleBuzz = false
        var elseValue: String = ""
    }
    
    enum Action {
        case fizzBuzzButtonTapped(value: Int)
        case updateStateElseValue(result: String)
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
                        switch result.type {
                        case "A":
                            await send(.updateStateElseValue(result: "AA"))
                        case "B":
                            let result2 = await fizzBuzzRepository.fetch2()
                            debugPrint("result is \(result2.type)")
                            switch result2.type {
                            case "X":
                                await send(.updateStateElseValue(result: "XX"))
                            case "Y":
                                await send(.updateStateElseValue(result: "YY"))
                            default:
                                await send(.updateStateElseValue(result: "BB"))
                            }
                        default:
                            await send(.updateStateElseValue(result: "CC"))
                        }
                    }
                }
                return .none
                
            case .updateStateElseValue(let value):
                state.elseValue = value
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
    
    public func testMethod() async -> FizzBuzzResult {
        return await fizzBuzzRepository.fetch1()
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
