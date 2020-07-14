//
//  WimbConstants.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import SwiftUI

enum SFSymbols {
    static let location = Image(systemName: "mappin.and.ellipse")
    static let repos = Image(systemName: "folder")
    static let gists = Image(systemName: "text.alignleft")
    static let followers = Image(systemName: "person.2")
    static let following = Image(systemName: "heart")
    static let deleteCircle = Image(systemName: "multiply.circle.fill")
    static let magnifyingglass = Image(systemName: "magnifyingglass")
    static let starfill = Image(systemName: "star.fill")
    static let plus = Image(systemName: "plus")
}

enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
}

enum Images {
    static let ghLogo = Image("gh-logo")
    static let emptyStateLogo = Image("empty-state-logo")
    static let avatarPlaceholder = Image("avatar-placeholder")
}

enum DeviceTypes {
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale

    static let isiPhoneSE = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad = idiom == .pad && ScreenSize.maxLength >= 1024.0

    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}
