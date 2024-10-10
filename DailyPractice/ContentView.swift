//
//  ContentView.swift
//  DailyPractice
//
//  Created by 山田　天星 on 2024/08/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ContentUnavailableSampleView()
                } label: {
                    Text("ContentUnavailableSample")
                }

                NavigationLink {
                    FooTabView()
                } label: {
                    Text("FooTabView")
                }
            }
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContentView()
}
