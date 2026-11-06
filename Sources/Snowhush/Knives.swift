import AppKit

enum Knives {
    /// The menu bar icon while knives fall: a dagger slanting down, point first, with a round pommel and a broad
    /// crossguard, drawn in outline like the symbols for the other modes.
    static let icon: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()
            // Laid out pointing right along the x axis, then turned to slant down.
            let blade = NSBezierPath()
            blade.move(to: NSPoint(x: -2.4, y: 1.3))
            blade.line(to: NSPoint(x: 9.2, y: 0))
            blade.line(to: NSPoint(x: -2.4, y: -1.3))
            blade.close()
            let guardBar = NSBezierPath(roundedRect: NSRect(x: -3.6, y: -3.4, width: 1.3, height: 6.8), xRadius: 0.6, yRadius: 0.6)
            let grip = NSBezierPath(rect: NSRect(x: -6.4, y: -0.8, width: 2.8, height: 1.6))
            let pommel = NSBezierPath(ovalIn: NSRect(x: -8.7, y: -1.25, width: 2.5, height: 2.5))
            var transform = AffineTransform(translationByX: 9, byY: 9)
            transform.rotate(byDegrees: -50)
            for path in [blade, guardBar, grip, pommel] {
                path.transform(using: transform)
                path.lineWidth = 1.1
                path.lineJoinStyle = .round
            }
            blade.stroke()
            guardBar.fill()
            grip.fill()
            pommel.fill()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Snowhush"
        return image
    }()
}
