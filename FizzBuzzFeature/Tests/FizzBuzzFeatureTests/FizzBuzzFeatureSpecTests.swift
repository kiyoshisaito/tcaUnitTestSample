//
//  FizzBuzzFeatureTests.swift
//  TcaSampleTests
//
//  Created by 斎藤基世志 on 2024/05/13.
//

import XCTest
import ComposableArchitecture
@testable import FizzBuzzFeature


final class FizzBuzzFeatureSpecTests: XCTestCase {
    private var store = TestStore(initialState: FizzBuzzFeature.State()) {
        FizzBuzzFeature()
    }
    private func createStore(
        fetch1: @escaping (() async -> FizzBuzzResult) = { FizzBuzzResult(type: "") },
        fetch2: @escaping (() async -> FizzBuzzResult2) = { FizzBuzzResult2(type: "") }
    ) -> TestStore<FizzBuzzFeature.State, FizzBuzzFeature.Action> {
        return TestStore(initialState: FizzBuzzFeature.State()) {
            FizzBuzzFeature()
        } withDependencies: {
            $0.fizzBuzzRepository.fetch1 = fetch1
            $0.fizzBuzzRepository.fetch2 = fetch2
        }
    }
    override func setUpWithError() throws {
        store = TestStore(initialState: FizzBuzzFeature.State()) {
            FizzBuzzFeature()
        }
    }
    @MainActor func test引数が3の倍数の場合() async {
        await store.send(.fizzBuzzButtonTapped(value: 3)) {
            "Fizz が 表示 される".it(&$0) { $0.isVisibleFizz = true }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が 非表示 になる".it(&$0) { $0.elseValue = "" }
        }
    }
    @MainActor func test引数が5の倍数の場合() async {
        await store.send(.fizzBuzzButtonTapped(value: 5)) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 表示 される".it(&$0) { $0.isVisibleBuzz = true }
            "その他 が 非表示 になる".it(&$0) { $0.elseValue = "" }
        }
    }
    @MainActor func test引数が3と5の倍数の場合() async {
        await store.send(.fizzBuzzButtonTapped(value: 15)) {
            "Fizz が 表示 される".it(&$0) { $0.isVisibleFizz = true }
            "Buzz が 表示 される".it(&$0) { $0.isVisibleBuzz = true }
            "その他 が 非表示 になる".it(&$0) { $0.elseValue = "" }
        }
    }
    @MainActor func test引数が3の倍数でも5の倍数でもない場合_取得結果1のタイプがAの場合() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "A") }
        )
        await store.send(.fizzBuzzButtonTapped(value: 4))
        await store.receive(\.updateStateElseValue) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が AA で表示 される".it(&$0) { $0.elseValue = "AA" }
        }
    }
    @MainActor func test引数が3の倍数でも5の倍数でもない場合_取得1のタイプがBの場合_取得2のタイプがXの場合() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "X") }
        )
        await store.send(.fizzBuzzButtonTapped(value: 4))
        await store.receive(\.updateStateElseValue) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が XX で表示 される".it(&$0) { $0.elseValue = "XX" }
        }
    }
    @MainActor func test引数が3の倍数でも5の倍数でもない場合_取得1のタイプがBの場合_取得2のタイプがYの場合() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "Y") }
        )
        await store.send(.fizzBuzzButtonTapped(value: 4))
        await store.receive(\.updateStateElseValue) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が YY で表示 される".it(&$0) { $0.elseValue = "YY" }
        }
    }
    @MainActor func test引数が3の倍数でも5の倍数でもない場合_取得1のタイプがBの場合_取得2のタイプがXでもYでもない場合() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "Z") }
        )
        await store.send(.fizzBuzzButtonTapped(value: 4))
        await store.receive(\.updateStateElseValue) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が BB で表示 される".it(&$0) { $0.elseValue = "BB" }
        }
    }
    @MainActor func test引数が3の倍数でも5の倍数でもない場合_取得1のタイプがCの場合() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "C") }
        )
        await store.send(.fizzBuzzButtonTapped(value: 4))
        await store.receive(\.updateStateElseValue) {
            "Fizz が 非表示 になる".it(&$0) { $0.isVisibleFizz = false }
            "Buzz が 非表示 になる".it(&$0) { $0.isVisibleBuzz = false }
            "その他 が CC で表示 される".it(&$0) { $0.elseValue = "CC" }
        }
    }
}

fileprivate extension String {
    func `it`<T>(_ state: inout T, assert: @escaping (inout T) -> Void) {
        assert(&state)
    }
}
