import SwiftUI

/// Wraps a row with a swipe-to-delete gesture, since the app's lists are hand-rolled VStacks
/// inside a ScrollView (not a List), where `.swipeActions` isn't available. Nothing is shown
/// during a small/partial swipe; only once the drag passes `fullSwipeThreshold` does the
/// revealed area turn red with a "Delete ..." label, and releasing there asks for confirmation.
/// A tap (when not dragging) fires `onTap`, e.g. to open an edit sheet.
struct SwipeToDeleteRow<Content: View>: View {
    let swipeLabel: String
    let confirmTitle: String
    let confirmMessage: String
    let onDelete: () -> Void
    var onTap: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        swipeLabel: String = L.deleteTransactionSwipeLabel,
        confirmTitle: String = L.deleteTransactionConfirmTitle,
        confirmMessage: String = L.deleteTransactionConfirmMessage,
        onDelete: @escaping () -> Void,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.swipeLabel = swipeLabel
        self.confirmTitle = confirmTitle
        self.confirmMessage = confirmMessage
        self.onDelete = onDelete
        self.onTap = onTap
        self.content = content
    }

    @State private var offset: CGFloat = 0
    @State private var showDeleteConfirm = false
    /// Absolute point distance rather than a fraction of the row's width — simpler and immune
    /// to a GeometryReader-measured width not landing before the gesture completes.
    private let fullSwipeThreshold: CGFloat = 220
    private let maxDragDistance: CGFloat = 320

    /// How far the row has been dragged left, in points.
    private var revealed: CGFloat { max(0, -offset) }
    private var isArmed: Bool { revealed >= fullSwipeThreshold }

    var body: some View {
        ZStack(alignment: .trailing) {
            // The red backdrop is only ever exactly as wide as the drag has revealed (never
            // the full row), so it can never sit behind — and show through gaps in — content
            // that hasn't slid out of the way yet.
            if isArmed {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Image(systemName: "trash.fill").font(.system(size: 15, weight: .semibold))
                    Text(swipeLabel).font(.system(size: 14.5, weight: .bold)).lineLimit(1)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white)
                .frame(width: revealed)
                .frame(maxHeight: .infinity)
                .background(AppColors.expense)
                .clipped()
            }

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { value in
                            offset = max(-maxDragDistance, min(0, value.translation.width))
                        }
                        .onEnded { _ in
                            if -offset >= fullSwipeThreshold {
                                showDeleteConfirm = true
                            } else {
                                close()
                            }
                        }
                )
                .onTapGesture { onTap?() }
        }
        .frame(maxWidth: .infinity)
        // Applies when this row is removed from its parent ForEach (see `delete()`): SwiftUI
        // animates the exit itself — sliding further in the swipe direction while fading out —
        // as one continuous motion together with the list collapsing to fill the gap, the same
        // way a native List's swipe-to-delete reads. No hand-timed second animation stage needed.
        .transition(.asymmetric(
            insertion: .opacity,
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .alert(confirmTitle, isPresented: $showDeleteConfirm) {
            Button(L.cancel, role: .cancel) { close() }
            Button(L.delete, role: .destructive) { delete() }
        } message: {
            Text(confirmMessage)
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            offset = 0
        }
    }

    private func delete() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            onDelete()
        }
    }
}
