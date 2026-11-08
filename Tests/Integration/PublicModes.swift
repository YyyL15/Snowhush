import Foundation
import Metal

@main struct PublicModesCheck {
    static func main() throws {
        let modes: [Mode] = [.snow, .autumn, .rain, .blossom, .knives, .dandelion, .fireflies]
        precondition(modes.map(\.rawValue) == Array(0...6))
        let capacity = 20000
        let buffer = UnsafeMutablePointer<Sprite>.allocate(capacity: capacity)
        defer { buffer.deallocate() }
        let simulation = SnowSimulation(width: 1440, height: 900, snowfall: .steady)
        for mode in modes {
            simulation.mode = mode
            for _ in 0..<900 { _ = simulation.step(dt: 1 / 30, cursor: SIMD2(-10000, -10000)) }
            let count = simulation.writeSprites(into: buffer, capacity: capacity)
            precondition(count > 0, "No particles in mode \(mode)")
            for i in 0..<count {
                let s = buffer[i]
                precondition(s.position.x.isFinite && s.position.y.isFinite && s.alpha.isFinite)
                precondition((s.knife != 0 ? 1 : 0) + (s.dandelion != 0 ? 1 : 0) + (s.firefly != 0 ? 1 : 0) <= 1)
                if mode == .knives { precondition(s.knife != 0 && s.dandelion == 0 && s.firefly == 0) }
                if mode == .dandelion { precondition(s.dandelion != 0 && s.knife == 0 && s.firefly == 0) }
                if mode == .fireflies { precondition(s.firefly != 0 && s.knife == 0 && s.dandelion == 0) }
                if mode.rawValue < 4 { precondition(s.knife == 0 && s.dandelion == 0 && s.firefly == 0) }
            }
            print("PASS mode \(mode): \(count) finite particles, isolated sprite fields")
        }
        // Read the actual CPU sprite array on the GPU to catch struct offset/stride mismatches.
        guard let device = MTLCreateSystemDefaultDevice() else {
            if CommandLine.arguments.contains("--require-metal") { fatalError("Metal unavailable") }
            print("SKIP Metal: run with --require-metal on a host with GPU access")
            return
        }
        let source = shaderSource + """
        \n kernel void inspectSprite(const device Sprite *s [[buffer(0)]], device float4 *out [[buffer(1)]], uint id [[thread_position_in_grid]]) {
            out[id] = float4(s[id].knife, s[id].dandelion, s[id].firefly, s[id].glow);
        }
        """
        let library = try device.makeLibrary(source: source, options: nil)
        for name in ["spriteVertex", "spriteFragment"] { precondition(library.makeFunction(name: name) != nil) }
        let pipeline = try device.makeComputePipelineState(function: library.makeFunction(name: "inspectSprite")!)
        let samples = [Sprite(position: .zero, size: 30, alpha: 1, soft: 0, knife: 0.25),
                       Sprite(position: .zero, size: 30, alpha: 1, soft: 0, dandelion: 0.5),
                       Sprite(position: .zero, size: 30, alpha: 1, soft: 0, firefly: 0.75, glow: 0.9)]
        let input = samples.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count, options: .storageModeShared)! }
        let output = device.makeBuffer(length: 3 * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)!
        let command = device.makeCommandQueue()!.makeCommandBuffer()!
        let encoder = command.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(input, offset: 0, index: 0)
        encoder.setBuffer(output, offset: 0, index: 1)
        encoder.dispatchThreads(MTLSize(width: 3, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 3, height: 1, depth: 1))
        encoder.endEncoding(); command.commit(); command.waitUntilCompleted()
        precondition(command.status == .completed)
        let values = output.contents().bindMemory(to: SIMD4<Float>.self, capacity: 3)
        precondition(values[0] == SIMD4(0.25, 0, 0, 0))
        precondition(values[1] == SIMD4(0, 0.5, 0, 0))
        precondition(values[2] == SIMD4(0, 0, 0.75, 0.9))
        print("PASS: Metal shader compilation and Swift/Metal Sprite offsets + stride")
    }
}
