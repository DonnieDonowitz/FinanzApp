import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == NotificationManager.reminderIdentifier {
            NotificationCenter.default.post(name: .openQuickAddExpense, object: nil)
        }
        completionHandler()
    }
}

@main
struct FinanzApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var vm = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .preferredColorScheme(vm.isDarkMode ? .dark : .light)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            BackgroundGradient()
            if vm.isLoading {
                ProgressView().tint(AppColors.text)
            } else {
                MainTabView(selectedTab: $selectedTab).environmentObject(vm)
            }

            if let level = vm.justLeveledUpTo {
                LevelUpOverlay(level: level) { vm.justLeveledUpTo = nil }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openQuickAddExpense)) { _ in
            selectedTab = 0
            vm.pendingQuickAddType = "expense"
        }
        .onOpenURL { url in
            guard url.scheme == "finanzapp", url.host == "add" else { return }
            let type = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "type" })?.value
            selectedTab = 0
            vm.pendingQuickAddType = type == "income" ? "income" : "expense"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var vm: AppViewModel
    @Binding var selectedTab: Int
    @State private var showTransactions = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // All four tabs are kept mounted (instead of switching which one exists), so
            // switching tabs is just an opacity toggle rather than tearing down and rebuilding
            // an entire glass-heavy view hierarchy. `selectedTab` lives here as a plain
            // @State/@Binding rather than on `vm` (an ObservableObject shared by all four
            // screens) — if it lived on `vm`, every tab switch would publish a change that
            // invalidates and re-renders all four already-mounted screens at once, which is
            // more work than the reconstruction this was meant to avoid.
            ZStack {
                HomeView(showTransactions: $showTransactions)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)
                    .accessibilityHidden(selectedTab != 0)
                StatisticsView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
                    .accessibilityHidden(selectedTab != 1)
                TransactionsView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 2)
                    .accessibilityHidden(selectedTab != 2)
                RecurringView()
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 3)
                    .accessibilityHidden(selectedTab != 3)
                SettingsView()
                    .opacity(selectedTab == 4 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 4)
                    .accessibilityHidden(selectedTab != 4)
            }
            .environmentObject(vm)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .sheet(isPresented: $showTransactions) {
            TransactionsView().environmentObject(vm)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            TabItem(icon: "house.fill", label: L.tabHome, isActive: selectedTab == 0, isDark: vm.isDarkMode)
                .onTapGesture { selectedTab = 0 }
            TabItem(icon: "chart.bar.fill", label: L.tabStatistics, isActive: selectedTab == 1, isDark: vm.isDarkMode)
                .onTapGesture { selectedTab = 1 }
            TabItem(icon: "list.bullet", label: L.tabMovements, isActive: selectedTab == 2, isDark: vm.isDarkMode)
                .onTapGesture { selectedTab = 2 }
            TabItem(icon: "arrow.triangle.2.circlepath", label: L.tabRecurring, isActive: selectedTab == 3, isDark: vm.isDarkMode)
                .onTapGesture { selectedTab = 3 }
            TabItem(icon: "gearshape.fill", label: L.tabSettings, isActive: selectedTab == 4, isDark: vm.isDarkMode)
                .onTapGesture { selectedTab = 4 }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial).saturation(1.55)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(AppColors.tabBar)
                LinearGradient(
                    stops: [.init(color: .white.opacity(vm.isDarkMode ? 0.10 : 0.55), location: 0), .init(color: .clear, location: 0.5)],
                    startPoint: .top, endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AppColors.tabBarBorder, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow.opacity(0.55), radius: 32, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(vm.isDarkMode ? 0.16 : 0.6), lineWidth: 1)
                .padding(1),
            alignment: .topLeading
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    let isDark: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isActive {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.primary.opacity(isDark ? 0.30 : 0.18))
                        .frame(width: 38, height: 30)
                }
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(isActive ? AppColors.tabActive : AppColors.tabInactive)
            }
            .frame(height: 30)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isActive ? AppColors.tabActive : AppColors.tabInactive)
                .tracking(0.1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}