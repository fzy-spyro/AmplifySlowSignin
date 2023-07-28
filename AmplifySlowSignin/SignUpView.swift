//
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

struct SignUpView: View {

    @EnvironmentObject var viewModel: SignInViewModel

    var body: some View {
        VStack(spacing: 10) {

            VStack {
                Group {
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

                    Button("Request OTP code!") {
                        Task {
                            do {
                                try await viewModel.signUp()
                            } catch {
                                print("Error requesting otp: \(error)")
                            }
                        }
                    }
                }

                Group {
                    VStack(alignment: .leading) {
                        Text("OTP code:")
                        TextField("otp code", text: $viewModel.otpCode)
                            .keyboardType(.decimalPad)
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 8)

                    Button("Confirm!") {
                        Task {
                            do {
                                try await viewModel.confirmUser()
                            } catch {
                                print("Error confirming: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
