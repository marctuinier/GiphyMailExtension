//
//  ContentView.swift
//  GIFMailSix
//
//  Created by Marc Tuinier on 9/16/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Gif Mail")
                .font(.title)
                .fontWeight(.bold)

            Text("The Mail extension is installed.\nYou can close this window.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("To enable the extension:")
                    .fontWeight(.medium)
                Text("1. Open System Settings")
                Text("2. General → Login Items & Extensions")
                Text("3. Mail Extensions → Enable Gif Mail")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            Button("Open Mail Extensions Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!)
            }
            .controlSize(.large)
        }
        .padding(32)
        .frame(width: 360)
    }
}
