//
//
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

struct ContentView: View {

    @State var username: String = ""

    var body: some View {
        VStack(spacing: 10) {

            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, \(username)")
            }

            Button("Sign out") {
                Task {
                    await Amplify.Auth.signOut()
                }
            }
        }
        .padding()
        .task {
            do {
                try await greetUser()
            } catch {
                print("error fetching user details: \(error)")
            }
        }
    }

    @MainActor
    func greetUser() async throws {
        let user = try await Amplify.Auth.getCurrentUser()
        username = user.username
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
