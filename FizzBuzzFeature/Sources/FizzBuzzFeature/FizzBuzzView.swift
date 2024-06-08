//
//  FizzBuzzView.swift
//  TcaSample
//
//  Created by 斎藤基世志 on 2024/05/13.
//

import ComposableArchitecture
import SwiftUI

struct FizzBuzzView: View {
    let store: StoreOf<FizzBuzzFeature>
    
    var body: some View {
        VStack {
            Button("FizzBuzz Start") {
                store.send(.fizzBuzzButtonTapped(value: 1))
            }
        }
    }
}
