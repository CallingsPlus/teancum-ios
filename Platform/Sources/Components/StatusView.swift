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
    
    var backgroundColor: Color {
        switch self {
        case .success: Color.green
        case .warning: Color.yellow
        case .failure: Color.red
        }
    }

    var textColor: Color {
        switch self {
        case .warning: Color.black // Darker color for better readability
        default: Color.white
        }
    }
}

public struct StatusView: View {
    public enum Action {
        case none
        case button(text: String, action: () -> Void)
    }
    
    let status: StatusType
    let message: String
    var action: Action = .none

    public init(status: StatusType, message: String, action: Action = .none) {
        self.status = status
        self.message = message
        self.action = action
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(status.emoji)
                .shadow(color: .gray, radius: 3, x: 0, y: 0)
            Text(message)
            
            if case let .button(text, action) = action {
                Button(text, action: action)
                    .foregroundColor(Color.white)
                    .padding(.trailing)
            }
        }
        .fontWeight(.medium)
        .foregroundColor(status.textColor)
        .padding()
        .background(status.backgroundColor)
        .cornerRadius(8)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StatusView(status: .success, message: "Operation completed successfully.")
            StatusView(status: .warning, message: "Please check your input.")
            StatusView(status: .failure, message: "Operation failed.")
            StatusView(status: .failure, message: "Operation failed.", action: .button(text: "Retry") {
                print("Retry action triggered.")
            })
        }
        .padding()
    }
}
