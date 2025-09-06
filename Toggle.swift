//
//
//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Foundation
import SwiftUI

struct BrownToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.brown : Color.gray)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10, y: 0)
                        .animation(Animation.linear(duration: 0.1), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .padding(.horizontal)
    }
}

struct YellowToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.yellow : Color.gray)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10, y: 0)
                        .animation(Animation.linear(duration: 0.1), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .padding(.horizontal)
    }
}
