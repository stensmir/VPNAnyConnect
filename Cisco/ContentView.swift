//
//  ContentView.swift
//  Cisco
//
//  Created by Юрий Дурнев on 22.01.2022.
//

import SwiftUI
import KeychainAccess
import Commands
import ShellOut

struct ContentView: View {
	
	@State private var pass: String = ""
	@State private var showPassword: Bool = false
	@State private var isConnect = false
	@State private var hideButtonTitle = "Показать"
	@State private var connectButtonTitle = "Подключить"
	private let keychain = Keychain(service: "com.vpn.cisco")
	private let staticTitle = "Введите свой пароль"

	var body: some View {
		VStack {
			Text("Ваш пароль:")
			HStack {
				if showPassword {
					
					TextField(staticTitle, text: $pass)
						.frame(width: 120, height: 30)
				} else {
					SecureField(staticTitle, text: $pass)
						.frame(width: 120, height: 30)
					
				}
				Button(hideButtonTitle) {
					showPassword.toggle()
					hideButtonTitle = showPassword ? "Скрыть" : "Показать"
				}
				
				Button("Сохранить") {
					keychain["password"] = pass
				}
			}
			
			Button(connectButtonTitle) {
				isConnect ? close() : runScript()
				connectButtonTitle = isConnect ? "Отключить" : "Подключить"
			}
		}.onAppear {
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
