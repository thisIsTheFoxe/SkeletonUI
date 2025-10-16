import SwiftUI
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SkeletonModifier: ViewModifier {
    let shape: ShapeType
    let animation: AnimationType
    let appearance: AppearanceType
    @State var animate: Bool = false

    public func body(content: Content) -> some View {
        content
            .modifier(SkeletonAnimatableModifier(animate ? 1 : 0, appearance))
            .clipShape(SkeletonShape(shape))
            .animation(animation.type, value: animate)
            .startOnce {
                guard !animate else { return }
                animate.toggle() 
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
