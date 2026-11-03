import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SkeletonModifier: ViewModifier {
    let shape: ShapeType
    let animation: AnimationType
    let appearance: AppearanceType
    @State var animate: Bool = false
    @State private var startDate = Date()

    public func body(content: Content) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            // Drive the shimmer phase from the clock instead of a `repeatForever` transaction,
            // so the animation can never leak onto layout changes (ours or the host app's).
            TimelineView(.animation(paused: animation == .none)) { context in
                content.modifier(SkeletonAnimatableModifier(
                    animation.phase(at: context.date.timeIntervalSince(startDate)),
                    appearance
                ))
            }
            .clipShape(SkeletonShape(shape))
        } else {
            content
                .modifier(SkeletonAnimatableModifier(animate ? 1 : 0, appearance))
                .animation(animation.type, value: animate)
                .clipShape(SkeletonShape(shape))
                .onAppear { DispatchQueue.main.async { animate = true } }
        }
    }
}


extension View {
    @ViewBuilder
    func startOnce(_ action: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.task { action() }
        } else {
            self.onAppear { DispatchQueue.main.async { action() } }
        }
    }
}
