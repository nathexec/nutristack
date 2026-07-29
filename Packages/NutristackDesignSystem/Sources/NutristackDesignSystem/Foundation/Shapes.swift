import SwiftUI

/// Hachures à 45° de la piste de la jauge d’actif (DS §7, jauge signature).
struct HatchShape: Shape {
    var step: CGFloat = 5
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var originX = -rect.height
        while originX < rect.width {
            path.move(to: CGPoint(x: originX, y: rect.height))
            path.addLine(to: CGPoint(x: originX + rect.height, y: 0))
            originX += step
        }
        return path
    }
}

/// Trait de coche dessiné (animable par `trim`), utilisé par la rangée de prise.
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.53))
        path.addLine(to: CGPoint(x: rect.width * 0.44, y: rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.width * 0.74, y: rect.height * 0.34))
        return path
    }
}

/// Contenant générique neutre, affiché quand aucun packshot conforme n’existe
/// (DS §2 : jamais de pastille colorée ni d’initiale).
struct GenericContainerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cap = CGRect(x: rect.width * 0.33, y: rect.height * 0.02,
                         width: rect.width * 0.34, height: rect.height * 0.13)
        let body = CGRect(x: rect.width * 0.20, y: rect.height * 0.20,
                          width: rect.width * 0.60, height: rect.height * 0.76)
        path.addRoundedRect(in: cap, cornerSize: CGSize(width: 3, height: 3))
        path.addRoundedRect(in: body, cornerSize: CGSize(width: rect.width * 0.12,
                                                         height: rect.width * 0.12))
        return path
    }
}
