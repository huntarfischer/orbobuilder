import SwiftUI

public enum IrisZodiacPalette {
    public static func color(for appearance: IrisZodiacAppearance) -> Color {
        switch (appearance.family, appearance.shade) {
        case (.fire, .light):
            return Color(red: 0.93, green: 0.42, blue: 0.36)
        case (.fire, .middle):
            return Color(red: 0.78, green: 0.24, blue: 0.20)
        case (.fire, .deep):
            return Color(red: 0.58, green: 0.13, blue: 0.12)

        case (.earth, .light):
            return Color(red: 0.48, green: 0.72, blue: 0.42)
        case (.earth, .middle):
            return Color(red: 0.31, green: 0.57, blue: 0.30)
        case (.earth, .deep):
            return Color(red: 0.19, green: 0.40, blue: 0.22)

        case (.air, .light):
            return Color(red: 0.96, green: 0.80, blue: 0.38)
        case (.air, .middle):
            return Color(red: 0.86, green: 0.65, blue: 0.20)
        case (.air, .deep):
            return Color(red: 0.69, green: 0.48, blue: 0.10)

        case (.water, .light):
            return Color(red: 0.43, green: 0.71, blue: 0.91)
        case (.water, .middle):
            return Color(red: 0.25, green: 0.54, blue: 0.80)
        case (.water, .deep):
            return Color(red: 0.13, green: 0.35, blue: 0.66)
        }
    }
}
