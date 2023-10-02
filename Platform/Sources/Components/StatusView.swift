import SwiftUI

public enum StatusType {
    case success
    case warning
    case failure
    
    var emoji: String {
        switch self {
        case .success:
            return "✅"
        case .warning:
            return "⚠️"
        case .failure:
            return "💣"
        }
    }
    
    var color: Color {
        switch self {
        case .success:
            return Color.green
        case .warning:
            return Color.yellow
        case .failure:
            return Color.red
        }
    }
}

public struct StatusView: View {
    let status: StatusType
    let message: String
    
    public init(status: StatusType, message: String) {
        self.status = status
        self.message = message
    }
    
    public var body: some View {
        Text(status.emoji + " " + message)
            .fontWeight(.medium)
            .foregroundColor(Color.white)
            .padding()
            .background(status.color)
            .cornerRadius(8)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StatusView(status: .success, message: "Operation completed successfully.")
            StatusView(status: .warning, message: "Please check your input.")
            StatusView(status: .failure, message: "Operation failed.")
        }
        .padding()
    }
}
