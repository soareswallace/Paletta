import UIKit

struct PaletteExporter {

    /// Renders a horizontal swatch strip as a UIImage suitable for sharing.
    static func image(from colors: [UIColor], format: ColorFormat) -> UIImage {
        let swatchWidth: CGFloat = 160
        let swatchHeight: CGFloat = 200
        let labelHeight: CGFloat = 40
        let totalWidth = swatchWidth * CGFloat(colors.count)
        let totalHeight = swatchHeight + labelHeight

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { ctx in
            for (i, color) in colors.enumerated() {
                let x = swatchWidth * CGFloat(i)

                // Swatch
                color.setFill()
                ctx.fill(CGRect(x: x, y: 0, width: swatchWidth, height: swatchHeight))

                // Label
                let label = colorLabel(for: color, format: format)
                let textColor = luminance(color) > 0.4 ? UIColor.black : UIColor.white
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 20, weight: .medium),
                    .foregroundColor: textColor
                ]
                let size = (label as NSString).size(withAttributes: attrs)
                let textX = x + (swatchWidth - size.width) / 2
                let textY = swatchHeight - size.height - 12
                (label as NSString).draw(at: CGPoint(x: textX, y: textY), withAttributes: attrs)

                // Bottom code on white strip
                UIColor.white.setFill()
                ctx.fill(CGRect(x: x, y: swatchHeight, width: swatchWidth, height: labelHeight))
                let codeAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 18, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
                let codeSize = (label as NSString).size(withAttributes: codeAttrs)
                let codeX = x + (swatchWidth - codeSize.width) / 2
                let codeY = swatchHeight + (labelHeight - codeSize.height) / 2
                (label as NSString).draw(at: CGPoint(x: codeX, y: codeY), withAttributes: codeAttrs)
            }
        }
    }

    private static func colorLabel(for color: UIColor, format: ColorFormat) -> String {
        switch format {
        case .hex: return color.hexString
        case .ral: return nearestRAL(to: color).code
        }
    }

    private static func luminance(_ color: UIColor) -> CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}
