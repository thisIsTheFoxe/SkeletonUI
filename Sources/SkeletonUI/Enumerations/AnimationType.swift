import SwiftUI

public enum AnimationType: Equatable {
    case none
    case pulse(duration: Double = 1.5, delay: Double = .zero, speed: Double = 1, autoreverses: Bool = true)
    case linear(duration: Double = 1.5, delay: Double = .zero, speed: Double = 1, autoreverses: Bool = false)
    
    var type: Animation? {
        switch self {
        case .none:
            return .none
        case let .pulse(duration, delay, speed, autoreverses):
            return Animation.easeIn(duration: duration).delay(delay).speed(speed).repeatForever(autoreverses: autoreverses)
        case let .linear(duration, delay, speed, autoreverses):
            return Animation.easeInOut(duration: duration).delay(delay).speed(speed).repeatForever(autoreverses: autoreverses)
        }
    }
}

extension AnimationType {
    /// Shimmer phase (0...1) at `elapsed` seconds, matching the `type` animation's timing.
    func phase(at elapsed: TimeInterval) -> CGFloat {
        switch self {
        case .none:
            return 0
        case let .pulse(duration, delay, speed, autoreverses):
            let t = Self.progress(elapsed, duration, delay, speed, autoreverses)
            return t * t // easeIn
        case let .linear(duration, delay, speed, autoreverses):
            let t = Self.progress(elapsed, duration, delay, speed, autoreverses)
            return t * t * (3 - 2 * t) // easeInOut
        }
    }

    private static func progress(_ elapsed: TimeInterval, _ duration: Double, _ delay: Double,
                                 _ speed: Double, _ autoreverses: Bool) -> CGFloat {
        guard duration > 0 else { return 0 }
        let cycles = max(0, elapsed - delay) * speed / duration
        let position = cycles.truncatingRemainder(dividingBy: autoreverses ? 2 : 1)
        // Run forward, then backward when autoreversing (triangle wave)
        return CGFloat(autoreverses && position > 1 ? 2 - position : position)
    }
}
