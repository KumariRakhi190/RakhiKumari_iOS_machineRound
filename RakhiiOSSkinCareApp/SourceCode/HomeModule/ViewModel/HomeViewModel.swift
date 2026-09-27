//
//  HomeViewModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//


import Foundation

class HomeViewModel {

    let careTypes: [CareType] = [
        CareType(name: "Face", applicationId: "19", imageName: "Face", backgroundColorHex: "#FCE4EC"),
        CareType(name: "Hair", applicationId: "21", imageName: "Hair", backgroundColorHex: "#E8F5E9"),
        CareType(name: "Eye", applicationId: "22", imageName: "Eye", backgroundColorHex: "#E3F2FD"),
        CareType(name: "Lips", applicationId: "23", imageName: "Lips", backgroundColorHex: "#FFF0F3"),
        CareType(name: "Teeth", applicationId: "24", imageName: "Teeth", backgroundColorHex: "#F3F8FF"),
        CareType(name: "Nail", applicationId: "25", imageName: "Nail", backgroundColorHex: "#FCEEF5"),
        CareType(name: "Hand", applicationId: "28", imageName: "Hand", backgroundColorHex: "#FFF3E0"),
        CareType(name: "Leg", applicationId: "29", imageName: "Leg", backgroundColorHex: "#F1F8E9")]
}
