//
//  ContentView.swift
//  Cisco
//
//  Created by Юрий Дурнев on 22.01.2022.
//

import SwiftUI
import KeychainAccess
import ShellOut
import LaunchAtLogin
import SwiftUIX

struct ContentView: View {

    enum Field: Hashable {
        case pass
        case address
        case userName
        case userCode
    }

    @State private var pass: String = ""
    @State private var address: String = ""
    @State private var showPassword: Bool = false
    @State private var isConnect = false
    @State private var connectButtonTitle = Loc.connect
    @State private var isLoading = false
    @State private var twoFA = false
    @State private var userName: String = ""
    @State private var userCode: String = ""
    @State private var progressForDefaultSector: CGFloat = 0.0
    @Environment(\.openURL) var openURL

    @FocusState private var focusedField: Field?

    private let keychain = Keychain(service: "com.vpn.cisco")

    var body: some View {
        VStack(alignment: .leading) {

            LaunchAtLogin.Toggle {
                Text(Loc.launchWithStart)
            }
            HStack {
                TextField(Loc.enterYourServer, text: $address)
                    .frame(width: 174, height: 30)
                    .focused($focusedField, equals: .address)
                    .onChange(of: address) {
                        keychain["address"] = $0
                    }
            }
            HStack {
                if showPassword {
                    TextField(Loc.enterYourPassword, text: $pass)
                        .frame(width: 130, height: 30)
                        .focused($focusedField, equals: .pass)
                        .onChange(of: pass) {
                            keychain["password"] = $0
                        }
                } else {
                    SecureField(Loc.enterYourPassword, text: $pass)
                        .focused($focusedField, equals: .pass)
                        .frame(width: 130, height: 30)
                        .onChange(of: pass) {
                            keychain["password"] = $0
                        }
                }
                Button {
                    showPassword.toggle()
                } label: {
                    let image = showPassword ? "eye.slash" : "eye"
                    HStack(alignment: .center) {
                        Image(systemName: image)
                            .resizable()
                            .renderingMode(.template)
                            .colorMultiply(.white)
                            .frame(width: 20, height: 14, alignment: .center)
                    }
                }
            }


            Divider().frame(width: 174, height: 1, alignment: .center)

            Text(Loc.needAuth).multilineTextAlignment(.leading).padding([.leading, .trailing], 5)
            HStack {
                TextField(Loc.enterName, text: $userName)
                    .focused($focusedField, equals: .userName)
                    .frame(width: 174, height: 30)
                    .onChange(of: userName) {
                        twoFA = !$0.isEmpty
                        keychain["name"] = $0
                    }
            }
            HStack {
                SecureField(Loc.enterCode, text: $userCode)
                    .focused($focusedField, equals: .userCode)
                    .frame(width: 174, height: 30)
                    .onChange(of: userCode) {
                        keychain["secret"] = $0
                    }
            }
            HStack {
                ActivityIndicator()
                    .animated(true)
                    .style(.small)
                    .hidden(!isLoading)
                Button(connectButtonTitle) {
                    if address.isEmpty {
                        focusedField = .address
                    } else if pass.isEmpty {
                        focusedField = .pass
                    }
                    isConnect ? close() : runScript()
                    connectStatus()
                }
                Button {
                    do {
                        let connecting = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn stats")
                        alert(subtitle: connecting)
                    } catch {
                        alert(subtitle: error.localizedDescription)
                    }
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "info.circle")
                            .resizable()
                            .renderingMode(.template)
                            .colorMultiply(.white)
                            .frame(width: 14, height: 14, alignment: .center)
                    }
                }
                Circle()
                    .fill(isConnect ? .green : .red)
                    .frame(width: 10, height: 10)
            }
            HStack {
                Button(Loc.exit) {
                    NSApplication.shared.terminate(self)
                }
                Button("GitHub") {
                    openURL(URL(string: "https://github.com/stensmir/VPNAnyConnect")!)
                }
            }.frame(width: 174, height: 30, alignment: .center)
            Spacer().frame(height: 10)
        }
        .padding(10)
        .onAppear {
            hasConnect()
            address = keychain["address"] ?? ""
            pass = keychain["password"] ?? ""
            userName = keychain["name"] ?? ""
            userCode = keychain["secret"] ?? ""
            twoFA = !userName.isEmpty
            focusedField = .address
        }
    }

    @discardableResult
    public func hasConnect() -> Bool {
        isLoading = true
        defer { isLoading.toggle() }
        do {
            let connecting = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn status | awk 'NR == 6{print $4; exit}'")
            isConnect = connecting == "Connected"
            connectStatus()
            return connecting == "Connected"
        } catch {
            alert(subtitle: error.localizedDescription)
            return false
        }
    }

    func connectStatus() {
        connectButtonTitle = isConnect ? Loc.disconnect : Loc.connect
        AppDelegate.instance.statusItem?.button?.image = NSImage(systemSymbolName: isConnect ? "shield.fill" : "shield", accessibilityDescription: nil)?
            .tinting(with: .white)

    }

    func close() {
        isLoading = true
        defer { isLoading.toggle() }
        do {
            try shellOut(to: "/opt/cisco/anyconnect/bin/vpn disconnect")
            isConnect.toggle()
        } catch {
            alert(subtitle: error.localizedDescription)
        }
    }

    func runScript() {
        isLoading = true
        defer { isLoading.toggle() }
        do {
            let output: String
            if twoFA {
                let code = try CodeGenerator(name: userName, code: userCode).generate()
                output = try shellOut(to: "printf \"\n\(pass)\n\(code)\" | /opt/cisco/anyconnect/bin/vpn -s connect \(address)")
            } else {
                output = try shellOut(to: "printf \"\n\(pass)\" | /opt/cisco/anyconnect/bin/vpn -s connect \(address)")
            }
            
            guard output.contains("Login failed") || output.contains("error:") else {
                isConnect.toggle()
                return
            }
            let error = (output.components(separatedBy: "error:").last ?? "")
                .replacingOccurrences(of: "VPN>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            alert(subtitle: error)
        } catch {
            alert(subtitle: error.localizedDescription)
        }
    }

    @discardableResult
    func alert(subtitle: String) -> Bool {
        let alert = NSAlert()
        alert.informativeText = subtitle
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: Loc.ok)
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
