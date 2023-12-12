import Foundation

public enum AllergyType: String, CaseIterable {
    case turbulence = "난류"
    case milk = "우유"
    case buckwheat = "메밀"
    case peanut = "땅콩"
    case soybean = "대두"
    case wheat = "밀"
    case mackerel = "고등어"
    case crab = "게"
    case shrimp = "새우"
    case pork = "돼지고기"
    case peach = "복숭아"
    case tomato = "토마토"
    case sulphite = "아황산염"
    case walnut = "호두"
    case chicken = "닭고기"
    case beef = "쇠고기"
    case squid = "오징어"
    case shellfish = "조개류"
}

public extension AllergyType {
    var number: String {
        switch self {
        case .turbulence:
            return "1."

        case .milk:
            return "2."

        case .buckwheat:
            return "3."

        case .peanut:
            return "4."

        case .soybean:
            return "5."

        case .wheat:
            return "6."

        case .mackerel:
            return "7."

        case .crab:
            return "8."

        case .shrimp:
            return "9."

        case .pork:
            return "10."

        case .peach:
            return "11."

        case .tomato:
            return "12."

        case .sulphite:
            return "13."

        case .walnut:
            return "14."

        case .chicken:
            return "15."

        case .beef:
            return "16."

        case .squid:
            return "17."

        case .shellfish:
            return "18."
        }
    }

    var image: String {
        switch self {
        case .turbulence:
            return "turbulence"

        case .milk:
            return "milk"

        case .buckwheat:
            return "buckwheat"

        case .peanut:
            return "peanut"

        case .soybean:
            return "soybean"

        case .wheat:
            return "wheat"

        case .mackerel:
            return "mackerel"

        case .crab:
            return "crab"

        case .shrimp:
            return "shrimp"

        case .pork:
            return "pork"

        case .peach:
            return "peach"

        case .tomato:
            return "tomato"

        case .sulphite:
            return "sulphite"

        case .walnut:
            return "walnut"

        case .chicken:
            return "chicken"

        case .beef:
            return "beef"

        case .squid:
            return "squid"

        case .shellfish:
            return "shellfish"
        }
    }
}
