//
//  ContentView.swift
//  KebabCalculator
//
//  Created by Илья Варфоломеев on 31.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ScrollView{
            PeopleCountView()
            DurationTimeView()
            MeatTypeView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
