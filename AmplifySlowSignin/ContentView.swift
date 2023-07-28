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
                Amplify.Auth.signOut() {
                    print("Signout result: \($0)")
                }
            }
        }
        .padding()
        .task {
            greetUser()
        }
    }

    @MainActor
    func greetUser(){
        let user = Amplify.Auth.getCurrentUser()
        username = user?.username ?? "Unknown"
    }
    
}
