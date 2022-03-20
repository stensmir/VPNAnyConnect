// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Loc {
  /// Connect
  public static let connect = Loc.tr("Localizable", "connect")
  /// Disconnect
  public static let disconnect = Loc.tr("Localizable", "disconnect")
  /// Secret
  public static let enterCode = Loc.tr("Localizable", "enterCode")
  /// Name
  public static let enterName = Loc.tr("Localizable", "enterName")
  /// Enter you password
  public static let enterYourPassword = Loc.tr("Localizable", "enterYourPassword")
  /// Server address
  public static let enterYourServer = Loc.tr("Localizable", "enterYourServer")
  /// Exit
  public static let exit = Loc.tr("Localizable", "exit")
  /// Launch app with start
  public static let launchWithStart = Loc.tr("Localizable", "launchWithStart")
  /// For One-time codes
  public static let needAuth = Loc.tr("Localizable", "needAuth")
  /// OK
  public static let ok = Loc.tr("Localizable", "ok")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
