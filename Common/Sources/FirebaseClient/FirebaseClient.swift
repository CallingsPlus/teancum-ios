import Firebase
import Logging

public enum FirebaseClient {
    public static func configure() {
        FirebaseApp.configure()
        LogEvent(.debug, "\(Self.self) configured").log()
    }
}
