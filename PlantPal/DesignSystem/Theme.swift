import SwiftUI

/// Central palette + spacing tokens for PlantPal's glassmorphic system.
enum Theme {
    // Brand
    static let leaf = Color(red: 0.259, green: 0.612, blue: 0.396)        // primary green
    static let leafDeep = Color(red: 0.145, green: 0.435, blue: 0.290)
    static let cream = Color(red: 0.98, green: 0.98, blue: 0.965)         // off-white ground

    // Status hues
    static let thirsty = Color(red: 0.93, green: 0.42, blue: 0.35)        // needs water (coral)
    static let soon = Color(red: 0.95, green: 0.72, blue: 0.30)           // due soon (amber)
    static let happy = Color(red: 0.33, green: 0.70, blue: 0.47)          // healthy (green)

    // Radii
    static let cardRadius: CGFloat = 26
    static let controlRadius: CGFloat = 20

    // Springs — fluid, interactive feel
    static let tapSpring = Animation.spring(response: 0.32, dampingFraction: 0.68)
    static let flowSpring = Animation.spring(response: 0.45, dampingFraction: 0.78)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}

/// Soft, layered background that lets the frosted glass read against a light ground.
struct PlantPalBackground: View {
    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            // Soft tinted blobs behind the glass
            Circle()
                .fill(Theme.happy.opacity(0.28))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: -140, y: -260)

            Circle()
                .fill(Theme.soon.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .offset(x: 160, y: -60)

            Circle()
                .fill(Theme.leaf.opacity(0.20))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(x: 120, y: 380)
        }
    }
}

extension View {
    /// Frosted-glass card surface — native Liquid Glass on iOS 26, material fallback below.
    @ViewBuilder
    func glassSurface(cornerRadius: CGFloat = Theme.cardRadius, tint: Color? = nil) -> some View {
        if #available(iOS 26, *) {
            let glass: Glass = tint.map { Glass.regular.tint($0.opacity(0.35)) } ?? .regular
            self.glassEffect(glass, in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(.white.opacity(0.45), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
        }
    }
}
