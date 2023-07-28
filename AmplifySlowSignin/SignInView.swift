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

    func signIn() async throws {
        print("⏰ \(#function) clicked!")
        let duration = try await ContinuousClock().measure {
            let result = try await Amplify.Auth.signIn(username: email, password: password, options: nil)
            print("Signin result: \(result)")
        }
        print("⏰ \(#function) finished!", duration)
    }

    func signUp() async throws {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
            } else {
                print("SignUp Complete")
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    func confirmUser() async throws {
        do {
            let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: otpCode)

            if case .done = result.nextStep {
                print("Confirmed!")
                showSignUpSheet = false
            } else {
                print("Unexpected result: \(result)")
            }

        } catch let error as AuthError {
            print("An error occurred while sonfirming a user \(error)")
        } catch {
            print("Unexpected error: \(error)")
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
                    Task {
                        do {
                            try await viewModel.signIn()
                        } catch {
                            print("Error signing in: \(error)")
                        }
                    }
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
