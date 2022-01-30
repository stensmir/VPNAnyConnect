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
	@State private var showPassword: Bool = false
	@State private var isConnect = false
	@State private var connectButtonTitle = "Подключить"
	private let keychain = Keychain(service: "com.vpn.cisco")
	private let staticTitle = "Введите свой пароль"
	
	var body: some View {
		VStack() {
			VStack {
				LaunchAtLogin.Toggle {
					Text("Запустить при старте")
				}
				HStack {
					if showPassword {
						
						TextField(staticTitle, text: $pass)
							.frame(width: 140, height: 30)
					} else {
						SecureField(staticTitle, text: $pass)
							.frame(width: 140, height: 30)
						
					}
					Button {
						showPassword.toggle()
					} label: {
						let image = showPassword ? "closeEye" : "openEye"
						HStack(alignment: .center, spacing: 5.0) {
							Image(image)
								.resizable()
								.renderingMode(.template)
								.colorMultiply(.white)
								.frame(width: 20, height: 20, alignment: .center)
						}
					}
					Button {
						keychain["password"] = pass
					} label: {
						HStack(alignment: .center, spacing: 5.0) {
							Image(systemName: "checkmark.circle")
								.resizable()
								.renderingMode(.template)
								.colorMultiply(.white)
								.frame(width: 15, height: 15, alignment: .center)
						}
					}
				}
				
			}
			Spacer().frame(height: 10)
			HStack {
				Button(connectButtonTitle) {
					isConnect ? close() : runScript()
					connectButtonTitle = isConnect ? "Отключить" : "Подключить"
				}
				Circle()
					.fill(isConnect ? .green : .red)
					.frame(width: 10, height: 10)
			}
			Spacer().frame(height: 10)
			Divider().frame(width: 230, height: 1, alignment: .center)
			Spacer().frame(height: 10)
			Button("Закрыть приложение") {
				NSApplication.shared.terminate(self)
			}
		}
		.padding(10)
		.onAppear {
			do {
				let connecting = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn status | awk 'NR == 6{print $4; exit}'")
				isConnect = connecting != "Disconnected"
				connectButtonTitle = isConnect ? "Отключить" : "Подключить"
				debugPrint(connecting)
			} catch {
				debugPrint(error)
			}
			pass = keychain["password"] ?? ""
		}
	}
	
	func close() {
		do {
			let close = try shellOut(to: "/opt/cisco/anyconnect/bin/vpn disconnect")
			debugPrint(close)
			isConnect.toggle()
		} catch {
			debugPrint(error)
		}
	}
	
	func runScript() {
		do {
			let connecting = try shellOut(to: "$(osascript -e 'display notification \"VPN is disconnected. Connecting...\" with title \"VPN\"')")
			let command = "printf \"\n\(pass)\" | /opt/cisco/anyconnect/bin/vpn -s connect vpn-ati-555.ati.su"
			let output = try shellOut(to: command)
			let connect = try shellOut(to: "$(osascript -e 'display notification \"VPN is connect\" with title \"VPN\"')")
			debugPrint(connecting, output, connect)
			isConnect.toggle()
		} catch {
			debugPrint(error)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
