//
//  CodeGenerator.swift
//  Cisco
//
//  Created by Юрий Дурнев on 20.03.2022.
//

import OneTimePassword
import Base32

enum TwoFaError: Error {
    case secterError, generateError
}

struct CodeGenerator {
    
    let name: String
    let code: String
    
    public func generate() throws -> String {
        let name = name
        let issuer = "default"
        let secretString = code

        guard let secretData = MF_Base32Codec.data(fromBase32String: secretString),
            !secretData.isEmpty else {
            throw TwoFaError.secterError
        }

        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6) else {
            throw TwoFaError.generateError
        }
        guard let code = Token(name: name, issuer: issuer, generator: generator)
            .currentPassword else {
            throw TwoFaError.secterError
        }
        return code
    }
}
