import Nest
import S4

extension S4.Headers {
    init(nestHeaders: [Nest.Header]) {
        var fields: [CaseInsensitiveString: S4.Header] = [:]
        for header in nestHeaders {
            fields[CaseInsensitiveString(header.0)] = S4.Header([header.1])
        }
        self.init(fields)
    }

    func toNestHeaders() -> [Nest.Header] {
        return headers.flatMap { (key, values) in
            if let value = values.first {
                return Nest.Header(key.string, value)
            }
            else {
                return nil
            }
        }
    }
}

extension S4.Method {
    init(string: String) {
        #if swift(>=3.0)
            let method = string.uppercased()
        #else
            let method = string.uppercaseString
        #endif
        switch method {
        case "DELETE":
            self = .delete
        case "GET":
            self = .get
        case "HEAD":
            self = .head
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "CONNECT":
            self = .connect
        case "OPTIONS":
            self = .options
        case "TRACE":
            self = .trace
        case "PATCH":
            self = .patch
        default:
            self = .other(method: method)
        }
    }
}



extension S4.Request {
    init(nestRequest: Nest.RequestType) {
        var nestRequest = nestRequest
        var body: Data = []
        if let payload = nestRequest.body {
            body = PayloadReader(payload: payload).read()
        }
        self.init(
            method: Method(string: nestRequest.method),
            uri: URI(path: nestRequest.path),
            headers: S4.Headers(nestHeaders: nestRequest.headers),
            body: body
        )
    }
}

extension S4.Response {
    init(nestResponse: Nest.ResponseType) {
        var body = Data()
        if let payload = nestResponse.body {
            body = PayloadReader(payload: payload).read()
        }
        var status = 200
        if let s = nestResponse.statusLine.characters.split(separator: " ").first {
            status = Int(String(s)) ?? status
        }
        self.init(
            status: S4.Status(statusCode: status),
            headers: S4.Headers(nestHeaders: nestResponse.headers),
            body: body
        )
    }
}
