import SwiftUI

private let accent  = Color(red: 0.776, green: 1.0,   blue: 0.239)
private let purple  = Color(red: 0.545, green: 0.361, blue: 1.0)
private let red     = Color(red: 1.0,   green: 0.329, blue: 0.439)
private let bg      = Color(red: 0.031, green: 0.027, blue: 0.047)

private struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let iconColors: [Color]
    let glowColor: Color
    let tag: String
    let title: String
    let subtitle: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        id: 0,
        icon: "chart.line.uptrend.xyaxis",
        iconColors: [purple, accent],
        glowColor: purple,
        tag: "REAL-TIME DATA",
        title: "Track Every\nMeme Coin",
        subtitle: "Live prices, charts, and rankings for the hottest meme coins — gainers, losers, trending, and more."
    ),
    OnboardingPage(
        id: 1,
        icon: "flame.fill",
        iconColors: [Color(red: 1, green: 0.55, blue: 0.1), Color(red: 1, green: 0.85, blue: 0.2)],
        glowColor: Color(red: 1, green: 0.6, blue: 0.1),
        tag: "TRENDS",
        title: "Spot What's\nHot Right Now",
        subtitle: "Filter by gainers, losers, most visited, and recently added. Switch timeframes in one tap."
    ),
    OnboardingPage(
        id: 2,
        icon: "star.fill",
        iconColors: [accent, Color(red: 0.2, green: 0.9, blue: 0.6)],
        glowColor: accent,
        tag: "WATCHLIST",
        title: "Watch Your\nFavorites",
        subtitle: "Star any coin to pin it to your watchlist. Full chart and market stats always one tap away."
    ),
    OnboardingPage(
        id: 3,
        icon: "brain.head.profile",
        iconColors: [red, purple],
        glowColor: red,
        tag: "SENTIMENT",
        title: "Fear & Greed\nAt a Glance",
        subtitle: "Track the market mood with a live Fear & Greed index so you always know when the herd is scared or greedy."
    ),
]

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var contentOffset: CGFloat = 40
    @State private var contentOpacity: Double = 0

    private var page: OnboardingPage { pages[currentPage] }
    private var isLast: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            RadialGradient(
                colors: [page.glowColor.opacity(0.22), .clear],
                center: .init(x: 0.5, y: 0.28),
                startRadius: 0, endRadius: 480
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if !isLast {
                        Button("Skip") { finish() }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(white: 1, opacity: 0.38))
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                    } else {
                        Color.clear.frame(height: 44)
                            .padding(.top, 18)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(page.glowColor.opacity(0.12))
                        .frame(width: 180, height: 180)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)

                    Circle()
                        .fill(page.glowColor.opacity(0.07))
                        .frame(width: 220, height: 220)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)

                    ZStack {
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .animation(.easeInOut(duration: 0.5), value: currentPage)

                        Image(systemName: page.icon)
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.92))
                            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                    }
                    .frame(width: 130, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .shadow(color: page.glowColor.opacity(0.45), radius: 28, y: 10)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                Spacer().frame(height: 52)

                Text(page.tag)
                    .font(.system(size: 11.5, weight: .bold))
                    .kerning(1.2)
                    .foregroundStyle(page.glowColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(page.glowColor.opacity(0.13), in: Capsule())
                    .overlay(Capsule().stroke(page.glowColor.opacity(0.28), lineWidth: 1))
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)

                Spacer().frame(height: 18)

                Text(page.title)
                    .font(.custom("Georgia-Bold", size: 38))
                    .foregroundStyle(.white)
                    .kerning(-0.8)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 30)
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)

                Spacer().frame(height: 18)

                Text(page.subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(white: 1, opacity: 0.52))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)

                Spacer()

                HStack(spacing: 7) {
                    ForEach(pages) { p in
                        Capsule()
                            .fill(p.id == currentPage ? accent : Color(white: 1, opacity: 0.18))
                            .frame(width: p.id == currentPage ? 24 : 7, height: 7)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                Button {
                    if isLast { finish() } else { advance() }
                } label: {
                    HStack(spacing: 10) {
                        Text(isLast ? "Get Started" : "Continue")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color(red: 0.06, green: 0.05, blue: 0.09))
                        Image(systemName: isLast ? "sparkles" : "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(red: 0.06, green: 0.05, blue: 0.09))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        LinearGradient(
                            colors: [accent, Color(red: 0.55, green: 1.0, blue: 0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: accent.opacity(0.38), radius: 18, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .animation(.easeInOut(duration: 0.2), value: isLast)
            }
        }
        .onAppear { animateIn() }
    }

    private func advance() {
        animateOut {
            currentPage += 1
            animateIn()
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        onFinish()
    }

    private func animateIn() {
        iconScale   = 0.55
        iconOpacity = 0
        contentOffset  = 36
        contentOpacity = 0
        withAnimation(.spring(response: 0.55, dampingFraction: 0.68).delay(0.05)) {
            iconScale   = 1
            iconOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.42).delay(0.18)) {
            contentOffset  = 0
            contentOpacity = 1
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        withAnimation(.easeIn(duration: 0.22)) {
            iconScale      = 0.75
            iconOpacity    = 0
            contentOpacity = 0
            contentOffset  = -24
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { completion() }
    }
}
