//
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var otpCode = ""

    @Published var showSignUpSheet = false

    func signIn() {
        print("⏰ \(#function) clicked!")
        let start = Date().timeIntervalSinceReferenceDate

        Amplify.Auth.signIn(username: email, password: password, options: nil) { result in
            print("Signin result: \(result)")
            let duration = Date().timeIntervalSinceReferenceDate - start
            print("⏰ \(#function) finished!", duration)
        }

    }

    func signUp() {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

        Amplify.Auth.signUp(username: email, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("SignUp Complete")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }

    func confirmUser() {
        Amplify.Auth.confirmSignUp(for: email, confirmationCode: otpCode) { [weak self] result in
            switch result {
            case .success(let authResult):
                if case .done = authResult.nextStep {
                    print("Confirmed!")
                    self?.showSignUpSheet = false
                } else {
                    print("Unexpected result: \(result)")
                }
            case .failure(let error):
                print("An error occurred while sonfirming a user \(error)")
            }
        }
    }
}

struct SignInView: View {

    @StateObject var viewModel = SignInViewModel()

    var body: some View {
        VStack(spacing: 10) {

            VStack {
                VStack(alignment: .leading) {
                    Text("Email:")
                    TextField("email", text: $viewModel.email)
                        .textCase(.lowercase)
                        .textInputAutocapitalization(.never)
                }
                .padding(.leading, 16)
                .padding(.bottom, 8)


                VStack(alignment: .leading) {
                    Text("Password:")
                    SecureField("password", text: $viewModel.password)
                }
                .padding(.leading, 16)
                .padding(.bottom, 8)

                Button("Sign in!") {
                    viewModel.signIn()
                }
            }

            Button("Sign me up!") {
                viewModel.showSignUpSheet = true
            }
            .padding(.top, 20)
            .sheet(isPresented: $viewModel.showSignUpSheet, onDismiss: {
                viewModel.showSignUpSheet = false
            }) {
                SignUpView()
                    .environmentObject(viewModel)
            }

        }
    }
}
