import UIKit

func nearestRAL(to color: UIColor) -> RALColor {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    return nearestRALColor(r: Float(red * 255), g: Float(green * 255), b: Float(blue * 255))
}
