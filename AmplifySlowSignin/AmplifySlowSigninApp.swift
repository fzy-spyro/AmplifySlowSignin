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

    func checkCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession {[weak self] result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                DispatchQueue.main.async {
                    self?.isSignedIn = session.isSignedIn
                }
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
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
                viewModel.checkCurrentAuthSession()
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
