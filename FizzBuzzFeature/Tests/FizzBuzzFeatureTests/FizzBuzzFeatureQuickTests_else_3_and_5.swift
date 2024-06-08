//
//  FizzBuzzFeatureQuickTests_else_3_and_5.swift
//  
//
//  Created by 斎藤基世志 on 2024/06/08.
//

import Quick
import Nimble
import ComposableArchitecture
@testable import FizzBuzzFeature

final class FizzBuzzFeatureQuickTests_else_3_and_5: AsyncSpec {

    override class func spec() {
        var store = createStore()
        func createStore(
            fetch1: @escaping (() async -> FizzBuzzResult) = { FizzBuzzResult(type: "") },
            fetch2: @escaping (() async -> FizzBuzzResult2) = { FizzBuzzResult2(type: "") }
        ) -> TestStore<FizzBuzzFeature.State, FizzBuzzFeature.Action> {
            let store = TestStore(initialState: FizzBuzzFeature.State()) {
                FizzBuzzFeature()
            } withDependencies: {
                $0.fizzBuzzRepository.fetch1 = fetch1
                $0.fizzBuzzRepository.fetch2 = fetch2
            }
            store.exhaustivity = .off
            return store
        }
        beforeEach {
            store = createStore()
        }
        
        var arg = 0
        func t(assert: @escaping (inout FizzBuzzFeature.State) -> Void) async {
            await store.send(.fizzBuzzButtonTapped(value: arg)) {
                assert(&$0)
            }
        }
        // fetch1 の result.type が B の場合の act
        func t2(assert: @escaping (inout FizzBuzzFeature.State) -> Void) async {
            await store.send(.fizzBuzzButtonTapped(value: arg))
            await store.receive(\.updateStateElseValue) {
                assert(&$0)
            }
        }
        
        describe("引数が3の倍数でも5の倍数でもない場合") {
            beforeEach {
                arg = 4
            }
            
            it("Fizz が 非表示 になる") { await t { $0.isVisibleFizz = false } }
            it("Buzz が 非表示 になる") { await t { $0.isVisibleBuzz = false } }
            
            context("取得結果1のタイプがAの場合") {
                beforeEach {
                    store = createStore(
                        fetch1: { FizzBuzzResult(type: "A") }
                    )
                }
                it("その他 が AA で表示 される") { await t2 { $0.elseValue = "AA" } }
            }
            
            context("取得結果1のタイプがBの場合") {
                context("取得2のタイプがXの場合") {
                    beforeEach {
                        store = createStore(
                            fetch1: { FizzBuzzResult(type: "B") },
                            fetch2: { FizzBuzzResult2(type: "X") }
                        )
                    }
                    it("その他 が XX で表示 される") { await t2 { $0.elseValue = "XX" } }
                }
                context("取得2のタイプがYの場合") {
                    beforeEach {
                        store = createStore(
                            fetch1: { FizzBuzzResult(type: "B") },
                            fetch2: { FizzBuzzResult2(type: "Y") }
                        )
                    }
                    it("その他 が YY で表示 される") { await t2 { $0.elseValue = "YY" } }
                }
                context("取得2のタイプがXでもYでもない場合") {
                    beforeEach {
                        store = createStore(
                            fetch1: { FizzBuzzResult(type: "B") },
                            fetch2: { FizzBuzzResult2(type: "Z") }
                        )
                    }
                    it("その他 が BB で表示 される") { await t2 { $0.elseValue = "BB" } }
                }
            }
            
            context("取得結果1のタイプがCの場合") {
                beforeEach {
                    store = createStore(
                        fetch1: { FizzBuzzResult(type: "C") }
                    )
                }
                it("その他 が CC で表示 される") { await t2 { $0.elseValue = "CC" } }
            }
        }
    }
}
