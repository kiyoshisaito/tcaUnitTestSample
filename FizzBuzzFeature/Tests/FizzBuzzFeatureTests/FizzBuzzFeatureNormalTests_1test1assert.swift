//
//  FizzBuzzFeatureNormalTests_t_pattern.swift
//
//
//  Created by 斎藤基世志 on 2024/06/08.
//

import XCTest
import ComposableArchitecture
@testable import FizzBuzzFeature

// TCAのテストフレームワーク＋XCTestCaseで日本語の仕様をコメントとメソッド名で表現
// さらに、stateの1プロパティ検証を1テストとしたもの。

final class FizzBuzzFeatureNormalTests_t_pattern: XCTestCase {
    private var store = TestStore(initialState: FizzBuzzFeature.State()) {
        FizzBuzzFeature()
    }
    private func createStore(
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
    override func setUpWithError() throws {
        store = createStore()
    }
    
    func t(arg: Int, assert: @escaping (inout FizzBuzzFeature.State) -> Void) async {
        await store.send(.fizzBuzzButtonTapped(value: arg)) {
            assert(&$0)
        }
    }

    // MARK: - 引数が3の倍数の場合
    @MainActor func test_引数が3の倍数_Fizzが表示() async {
        await t(arg: 3) { $0.isVisibleFizz = true }
    }
    @MainActor func test_引数が3の倍数_Buzzが非表示() async {
        await t(arg: 3) { $0.isVisibleBuzz = false }
    }
    @MainActor func test_引数が3の倍数_その他が非表示() async {
        await t(arg: 3) { $0.elseValue = "" }
    }
    // MARK: - 引数が5の倍数の場合
    @MainActor func test_引数が5の倍数_Fizzが非表示() async {
        await t(arg: 5) { $0.isVisibleFizz = false }
    }
    @MainActor func test_引数が5の倍数_Buzzが表示() async {
        await t(arg: 5) { $0.isVisibleBuzz = true }
    }
    @MainActor func test_引数が5の倍数_その他が非表示() async {
        await t(arg: 5) { $0.elseValue = "" }
    }
    // MARK: - 引数が3と5の倍数の場合
    @MainActor func test_引数が3と5の倍数_Fizzが表示() async {
        await t(arg: 15) { $0.isVisibleFizz = true }
    }
    @MainActor func test_引数が3と5の倍数_Buzzが表示() async {
        await t(arg: 15) { $0.isVisibleBuzz = true }
    }
    @MainActor func test_引数が3と5の倍数_その他が非表示() async {
        await t(arg: 15) { $0.elseValue = "" }
    }
    // MARK: - 引数が3の倍数でも5の倍数でもない場合
    func t2(arg: Int, assert: @escaping (inout FizzBuzzFeature.State) -> Void) async {
        await store.send(.fizzBuzzButtonTapped(value: arg))
        await store.receive(\.updateStateElseValue) {
            assert(&$0)
        }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_Fizzが非表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "A") }
        )
        await t2(arg: 4) { $0.isVisibleFizz = false }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_Buzzが非表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "A") }
        )
        await t2(arg: 4) { $0.isVisibleBuzz = false }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_取得結果1のタイプがAの場合_その他がAAで表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "A") }
        )
        await t2(arg: 4) { $0.elseValue = "AA" }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_取得1のタイプがB_取得2のタイプがX_その他がXXで表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "X") }
        )
        await t2(arg: 4) { $0.elseValue = "XX" }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_取得1のタイプがB_取得2のタイプがY_その他がYYで表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "Y") }
        )
        await t2(arg: 4) { $0.elseValue = "YY" }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_取得1のタイプがB_取得2のタイプがXでもYでもない_その他がBBで表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "B") },
            fetch2: { FizzBuzzResult2(type: "Z") }
        )
        await t2(arg: 4) { $0.elseValue = "BB" }
    }
    @MainActor func test_引数が3の倍数でも5の倍数でもない_取得1のタイプがC_その他がCCで表示() async {
        store = createStore(
            fetch1: { FizzBuzzResult(type: "C") }
        )
        await t2(arg: 4) { $0.elseValue = "CC" }
    }
}
