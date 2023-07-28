//
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false

    private var authToken: AnyCancellable?

    init() {
        authToken = Amplify.Hub.publisher(for: .auth)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
            switch payload.eventName {
            case HubPayload.EventName.Auth.signedIn:
                self?.isSignedIn = true
            case HubPayload.EventName.Auth.signedOut:
                self?.isSignedIn = false
            default:
                break
            }
        }
    }

    deinit {
        authToken?.cancel()
        authToken = nil
    }

    @MainActor
    func checkCurrentAuthSession() async throws {
        let session = try await Amplify.Auth.fetchAuthSession()
        print("Is user signed in - \(session.isSignedIn)")
        isSignedIn = session.isSignedIn
    }
}

@main
struct AmplifySlowSigninApp: App {

    @StateObject var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isSignedIn {
                    ContentView()
                } else {
                    SignInView()
                }
            }
            .task {
                do {
                    try await viewModel.checkCurrentAuthSession()
                } catch {
                    print("Error when checking session: \(error)")
                }
            }
        }
    }
    
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }

}
