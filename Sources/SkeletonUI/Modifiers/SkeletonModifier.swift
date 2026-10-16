import SwiftUI
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct SkeletonModifier: ViewModifier {
    let shape: ShapeType
    let animation: AnimationType
    let appearance: AppearanceType
    @State var animate: Bool = false

    public func body(content: Content) -> some View {
        Group {
            if #available(iOS 17, macOS 14, tvOS 17.0, watchOS 10.0) {
                content
                .animation(animation.type) { view in 
                    view.modifier(SkeletonAnimatableModifier(animate ? 1 : 0, appearance))
                }
            } else {
            content
                .modifier(SkeletonAnimatableModifier(animate ? 1 : 0, appearance))
                .animation(animation.type, value: animate)
            }
        }
        .clipShape(SkeletonShape(shape))
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
