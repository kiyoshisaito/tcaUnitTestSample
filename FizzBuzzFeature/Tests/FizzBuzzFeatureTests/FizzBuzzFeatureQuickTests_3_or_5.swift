//
//  FizzBuzzFeatureQuickTests.swift
//  TcaSampleTests
//
//  Created by 斎藤基世志 on 2024/06/07.
//

import Quick
import Nimble
import ComposableArchitecture
@testable import FizzBuzzFeature


final class FizzBuzzFeatureQuickTests_3_or_5: AsyncSpec {
    
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
        
        describe("引数が3の倍数の場合") {
            beforeEach {
                arg = 3
            }
            it("Fizz が 表示 される") { await t { $0.isVisibleFizz = true } }
            it("Buzz が 非表示 になる") { await t { $0.isVisibleBuzz = false } }
            it("その他 が 非表示 になる") { await t { $0.elseValue = "" } }
        }
        
        describe("引数が5の倍数の場合") {
            beforeEach {
                arg = 5
            }
            it("Fizz が 非表示 になる") { await t { $0.isVisibleFizz = false } }
            it("Buzz が 表示 される") { await t { $0.isVisibleBuzz = true } }
            it("その他 が 非表示 になる") { await t { $0.elseValue = "" } }
        }
        
        describe("引数が3と5の倍数の場合") {
            beforeEach {
                arg = 15
            }
            it("Fizz が 表示 される") { await t { $0.isVisibleFizz = true } }
            it("Buzz が 表示 される") { await t { $0.isVisibleBuzz = true } }
            it("その他 が 非表示 になる") { await t { $0.elseValue = "" } }
        }
    }
}
