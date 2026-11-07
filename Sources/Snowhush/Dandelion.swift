import AppKit

enum Dandelion {
    /// The menu bar icon while dandelion seeds drift: a seed with its fan of hairs above a fine beak, drawn in outline
    /// like the symbols for the other modes.
    static let icon: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()
            let crown = NSPoint(x: 9, y: 9.5)
            let beak = NSBezierPath()
            beak.move(to: NSPoint(x: 9, y: 3.2))
            beak.line(to: crown)
            beak.lineWidth = 1.1
            beak.stroke()
            NSBezierPath(ovalIn: NSRect(x: 8.2, y: 0.6, width: 1.6, height: 3.2)).fill()
            for k in 0..<7 {
                let angle = (-1.2 + 2.4 * CGFloat(k) / 6)
                let end = NSPoint(x: crown.x + sin(angle) * 7, y: crown.y + cos(angle) * 7)
                let hair = NSBezierPath()
                hair.move(to: crown)
                hair.line(to: end)
                hair.lineWidth = 0.9
                hair.lineCapStyle = .round
                hair.stroke()
                NSBezierPath(ovalIn: NSRect(x: end.x - 0.9, y: end.y - 0.9, width: 1.8, height: 1.8)).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Snowhush"
        return image
    }()
}
