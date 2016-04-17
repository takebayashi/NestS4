import Nest
import S4

struct FixedPayload: Nest.PayloadType {
    var buffer: [Byte]
    mutating func next() -> [UInt8]? {
        if buffer.count > 0 {
            return buffer
        }
        return nil
    }
}

struct StreamPayload: Nest.PayloadType {
    var stream: ReceivingStream

    mutating func next() -> [UInt8]? {
        do {
            return try stream.receive(upTo: 128, timingOut: 10).bytes
        } catch {
            return nil
        }
    }
}

struct NestRequest: Nest.RequestType {
    var method: String
    var path: String
    var headers: [Nest.Header]
    var body: PayloadType?

    init(s4Request: S4.Request) {
        self.method = s4Request.method.description
        self.path = s4Request.uri.path ?? "/"
        self.headers = s4Request.headers.toNestHeaders()
        switch s4Request.body {
        case let .buffer(buffer):
            self.body = FixedPayload(buffer: buffer.bytes)
        case let .receiver(stream):
            self.body = StreamPayload(stream: stream)
        default:
            self.body = FixedPayload(buffer: [])
        }
    }
}
