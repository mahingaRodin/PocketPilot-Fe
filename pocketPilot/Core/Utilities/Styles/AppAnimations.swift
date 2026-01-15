
import SwiftUI

extension Animation {
    /// A bouncy spring animation for interactive elements like buttons
    static var springy: Animation {
        .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)
    }
    
    /// A smooth, gentle animation for content appearing
    static var gentle: Animation {
        .easeInOut(duration: 0.4)
    }
    
    /// A slightly delayed animation for staggered effects
    static func staggered(index: Int) -> Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
        .delay(Double(index) * 0.05)
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
