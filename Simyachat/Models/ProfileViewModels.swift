//
//  ProfileViewModels.swift
//  Simyachat
//
//  Created by Nizamet Özkan on 23.07.2020.
//  Copyright © 2020 Nizamet Özkan. All rights reserved.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}
struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
