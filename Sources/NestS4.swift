import Nest
import S4


class PayloadReader {
    var payload: PayloadType

    init(payload: PayloadType) {
        self.payload = payload
    }

    func read() -> Data {
        var bytes: [UInt8] = []
        while let chunk = payload.next() {
            bytes.append(contentsOf: chunk)
        }
        return Data(bytes)
    }
}

public class NestResponder: S4.Responder {
    let nestApp: Nest.Application

    public init(nestApp: Nest.Application) {
        self.nestApp = nestApp
    }

    public func respond(to request: S4.Request) throws -> S4.Response {
        let nestResponse = nestApp(NestRequest(s4Request: request))
        return S4.Response(nestResponse: nestResponse)
    }
}
