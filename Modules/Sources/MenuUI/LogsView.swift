import SwiftUI

public class LogsState: ObservableObject {
    public init() {}
    
    @Published public var logs: [Log] = []
}

public struct Log {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
}

public struct LogsView: View {
    public init(logsState: LogsState) {
        self.logsState = logsState
    }
    
    @ObservedObject private var logsState: LogsState
    
    public var body: some View {
        List($logsState.logs, id: \.value) { $log in
            Text(log.value).textSelection(.enabled)
        }
    }
}
