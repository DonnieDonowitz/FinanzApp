import SwiftUI

/// A flat, minimal card surface: solid fill, thin hairline border, one soft shadow for
/// separation from the background. No translucent material, no gradient sheen — the
/// previous "liquid glass" treatment made surfaces read as busy and reduced text contrast.
struct GlassView<Content: View>: View {
    let intensity: GlassIntensity
    let radius: CGFloat
    let content: () -> Content
    @EnvironmentObject var vm: AppViewModel

    init(intensity: GlassIntensity = .regular, radius: CGFloat = 22, @ViewBuilder content: @escaping () -> Content) {
        self.intensity = intensity
        self.radius = radius
        self.content = content
    }

    private var bg: Color { intensity == .regular ? AppColors.glass : AppColors.glassStrong }
    private var border: Color { intensity == .regular ? AppColors.glassBorder : AppColors.glassBorderStrong }

    var body: some View {
        content()
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            .shadow(color: AppColors.shadow, radius: 10, x: 0, y: 3)
    }
}

enum GlassIntensity { case regular, strong }

extension View {
    func glass(intensity: GlassIntensity = .regular, radius: CGFloat = 22) -> some View {
        GlassView(intensity: intensity, radius: radius) { self }
    }
}
