import NutristackDomain

extension Product {
    /// Forme abrégée du nom, employée là où la place manque : ligne
    /// « À surveiller », tuile de prochain rachat, message de confirmation.
    /// La maquette abrège au premier mot (« Créatine », « Magnésium »).
    ///
    /// Convention d’affichage et non règle métier : elle vit donc dans la
    /// couche applicative, en un seul endroit plutôt que dans chaque écran.
    var shortName: String {
        name.components(separatedBy: " ").first ?? name
    }
}
