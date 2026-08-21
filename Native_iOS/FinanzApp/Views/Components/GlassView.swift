import SwiftUI

struct GlassView<Content: View>: View {
    let intensity: GlassIntensity
    let radius: CGFloat
    let content: () -> Content
    @EnvironmentObject var vm: AppViewModel

    init(intensity: GlassIntensity = .regular, radius: CGFloat = 28, @ViewBuilder content: @escaping () -> Content) {
        self.intensity = intensity
        self.radius = radius
        self.content = content
    }

    private var bg: Color { intensity == .regular ? AppColors.glass : AppColors.glassStrong }
    private var border: Color { intensity == .regular ? AppColors.glassBorder : AppColors.glassBorderStrong }
    private var highlight: Color { intensity == .regular ? AppColors.glassHighlight : AppColors.glassHighlightStrong }
    private var shadowOpacity: Double { vm.isDarkMode ? 0.45 : 0.18 }
    private var insetOpacity: Double { vm.isDarkMode ? 0.22 : 0.7 }

    var body: some View {
        content()
            // Specular sheen: a bright diagonal highlight sweeping the top-leading corner,
            // like light catching the curved surface of real glass.
            .background(
                LinearGradient(
                    stops: [
                        .init(color: highlight, location: 0),
                        .init(color: highlight.opacity(0.4), location: 0.18),
                        .init(color: .clear, location: 0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            // Faint cool-toned refraction wash from the opposite corner for depth.
            .background(
                RadialGradient(
                    colors: [AppColors.accent.opacity(vm.isDarkMode ? 0.10 : 0.06), .clear],
                    center: .bottomTrailing, startRadius: 0, endRadius: 220
                )
            )
            .background(bg)
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .saturation(1.55)
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
            // Crisp bright rim along the top edge — the hallmark of a glass bevel.
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .trim(from: 0.58, to: 1.0)
                    .stroke(Color.white.opacity(insetOpacity), lineWidth: 1.2)
                    .padding(0.6)
            )
            // Soft inner shadow along the bottom edge for a sense of thickness.
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .trim(from: 0.02, to: 0.48)
                    .stroke(Color.black.opacity(vm.isDarkMode ? 0.22 : 0.08), lineWidth: 1.2)
                    .padding(0.6)
            )
            .shadow(color: AppColors.shadow.opacity(shadowOpacity), radius: 30, x: 0, y: 10)
            .shadow(color: .white.opacity(vm.isDarkMode ? 0.03 : 0.5), radius: 1, x: 0, y: 1)
    }
}

enum GlassIntensity { case regular, strong }

extension View {
    func glass(intensity: GlassIntensity = .regular, radius: CGFloat = 28) -> some View {
        GlassView(intensity: intensity, radius: radius) { self }
    }
}
