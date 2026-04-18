//
//  SplashView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 19/4/26.
//

import SwiftUI

// MARK: - Splash view
struct SplashView: View {

    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: Double = 10
    @State private var badgeOpacity: Double = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
                .preferredColorScheme(.light)

            VStack(spacing: 0) {

                Spacer()

                // MARK: Logo area
                VStack(spacing: 24) {

                    // Drop icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.08))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(Color.red.opacity(0.14))
                            .frame(width: 90, height: 90)

                        Image(systemName: "drop.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.red)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // App name
                    VStack(spacing: 6) {
                        Text("BloodLink")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        Text("Connecting donors with those\nwho need them most.")
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                            .multilineTextAlignment(.center)
                            .offset(y: taglineOffset)
                    }
                    .opacity(taglineOpacity)
                }

                Spacer()

                // MARK: Bottom badge
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                        Text("Anonymous · Secure · Private")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }

                    HStack(spacing: 20) {
                        FeaturePill(icon: "drop.fill",      label: "Donate",   color: .red)
                        FeaturePill(icon: "magnifyingglass", label: "Find",    color: .blue)
                        FeaturePill(icon: "message.fill",   label: "Connect",  color: .green)
                    }
                }
                .opacity(badgeOpacity)
                .padding(.bottom, 52)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Animation sequence
    func startAnimation() {

        // Step 1 — fade in logo
        withAnimation(.easeOut(duration: 0.7)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Step 2 — fade in tagline
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            taglineOpacity = 1
            taglineOffset = 0
        }

        // Step 3 — fade in bottom badges
        withAnimation(.easeOut(duration: 0.5).delay(0.9)) {
            badgeOpacity = 1
        }

        // Step 4 — navigate to login after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFinished = true
            }
        }
    }
}

// MARK: - Feature pill
struct FeaturePill: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    SplashView()
}
