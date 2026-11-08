import AppKit

struct WindowUpdate {
    let surfaces: [WindowSurface]
    /// Seconds since the previous poll.
    let interval: Float
    /// Windows that left the list but still exist off screen, where it can't be told whether they were hidden
    /// or left behind on another Space.
    let parked: Set<CGWindowID>
    /// Windows left behind on another Space: their snow waits for them.
    let elsewhere: Set<CGWindowID>
    /// The whole Space is sliding past, as on a switch between Spaces: windows move without being moved.
    let sliding: Bool
    /// How fast the sliding Space carried its windows since the previous poll, in points a second, negative to
    /// the left; zero when it didn't.
    let slideVelocity: Float
}

struct WindowSurface: Equatable {
    let id: CGWindowID
    /// Overlay coordinates: origin at the bottom-left of the primary screen.
    let frame: CGRect
    /// Frames of windows in front of this one near its top edge, in overlay coordinates.
    let blockers: [CGRect]
    /// Frames of windows in front of any part of this one: what hides a drop running down it.
    let cover: [CGRect]
    /// Top corners as a superellipse quadrant: macOS windows are close to exponent 2.5, Spotlight's capsule is a circle.
    let cornerRadius: CGFloat
    let cornerExponent: CGFloat
    /// The Dock's shelf: its snow is drawn below the Dock, so the icons stay in front of it.
    let isDock: Bool

    func shifted(by dx: CGFloat) -> WindowSurface {
        WindowSurface(
            id: id,
            frame: frame.offsetBy(dx: dx, dy: 0),
            blockers: blockers.map { $0.offsetBy(dx: dx, dy: 0) },
            cover: cover.map { $0.offsetBy(dx: dx, dy: 0) },
            cornerRadius: cornerRadius,
            cornerExponent: cornerExponent,
            isDock: isDock
        )
    }
}

