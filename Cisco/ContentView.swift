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

struct ContentView: View {
	
	@State private var pass: String = ""
	@State private var address: String = ""
	@State private var showPassword: Bool = false
	@State private var isConnect = false
	@State private var connectButtonTitle = Loc.connect
	@State private var isLoading = false
    @State private var twoFA = false
    @State private var userName: String = ""
    @State private var userCode: String = ""
    
	private let keychain = Keychain(service: "com.vpn.cisco")
	
	var body: some View {
		VStack() {
			VStack {
				LaunchAtLogin.Toggle {
					Text(Loc.launchWithStart)
				}
				HStack {
					TextField(Loc.enterYourServer, text: $address)
						.frame(width: 140, height: 30)
					Button {
						keychain["address"] = address
					} label: {
						HStack(alignment: .center) {
							Image(systemName: "checkmark.circle")
								.resizable()
								.renderingMode(.template)
								.colorMultiply(.white)
								.frame(width: 14, height: 14, alignment: .center)
						}
					}
				}
				HStack {
					if showPassword {
						TextField(Loc.enterYourPassword, text: $pass)
							.frame(width: 140, height: 30)
					} else {
						SecureField(Loc.enterYourPassword, text: $pass)
							.frame(width: 140, height: 30)
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
					Button {
						keychain["password"] = pass
					} label: {
						HStack(alignment: .center) {
							Image(systemName: "checkmark.circle")
								.resizable()
								.renderingMode(.template)
								.colorMultiply(.white)
								.frame(width: 14, height: 14, alignment: .center)
						}
					}
				}
			}
			Spacer().frame(height: 10)
            Divider().frame(width: 230, height: 1, alignment: .center)
            VStack {
                Label(Loc.needAuth, image: "")
                HStack {
                    TextField(Loc.enterName, text: $userName)
                        .frame(width: 140, height: 30)
                    Button {
                        twoFA = true
                        keychain["name"] = userName
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .renderingMode(.template)
                                .colorMultiply(.white)
                                .frame(width: 14, height: 14, alignment: .center)
                        }
                    }
                }
                HStack {
                    SecureField(Loc.enterCode, text: $userCode)
                        .frame(width: 140, height: 30)
                    Button {
                        keychain["secret"] = userCode
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .renderingMode(.template)
                                .colorMultiply(.white)
                                .frame(width: 14, height: 14, alignment: .center)
                        }
                    }
                }
            }
			HStack {
				Button(connectButtonTitle) {
					isConnect ? close() : runScript()
					connectStatus()
				}
				Circle()
					.fill(isConnect ? .green : .red)
					.frame(width: 10, height: 10)
				
				Button {
					isLoading = false
					do {
						let connecting = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn stats")
						let _ = alert(subtitle: connecting)
					} catch {
						let _ = alert(subtitle: error.localizedDescription)
					}
					isLoading = true
				} label: {
					HStack(alignment: .center) {
						Image(systemName: "info.circle")
							.resizable()
							.renderingMode(.template)
							.colorMultiply(.white)
							.frame(width: 14, height: 14, alignment: .center)
					}
				}
			}
			Spacer().frame(height: 10)
			Divider().frame(width: 230, height: 1, alignment: .center)
			Spacer().frame(height: 10)
			Button(Loc.exit) {
				NSApplication.shared.terminate(self)
			}
		}
		.padding(10)
		.onAppear {
			hasConnect()
			address = keychain["address"] ?? ""
			pass = keychain["password"] ?? ""
            userName = keychain["name"] ?? ""
            userCode = keychain["secret"] ?? ""
            twoFA = !userName.isEmpty
		}
	}
    
	@discardableResult
	public func hasConnect() -> Bool {
		do {
			let connecting = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn status | awk 'NR == 6{print $4; exit}'")
			isConnect = connecting == "Connected"
			connectStatus()
			return connecting == "Connected"
		} catch {
			let _ = alert(subtitle: error.localizedDescription)
			return false
		}
	}
	
	func connectStatus() {
		connectButtonTitle = isConnect ? Loc.disconnect : Loc.connect
		AppDelegate.instance.statusItem?.button?.image = NSImage(systemSymbolName: isConnect ? "shield.fill" : "shield", accessibilityDescription: nil)?
			.tinting(with: .white)
	}
	
	func close() {
		do {
			let _ = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn disconnect")
			isConnect.toggle()
		} catch {
			let _ = alert(subtitle: error.localizedDescription)
		}
	}
	
	func runScript() {
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
			let _ = alert(subtitle: error)
		} catch {
			let _ = alert(subtitle: error.localizedDescription)
		}
	}
	
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
