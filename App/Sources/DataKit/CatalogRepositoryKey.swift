import SwiftUI

/// Injection du dépôt de catalogue par l’environnement.
///
/// Les écrans lisent `\.catalogRepository` et ne nomment jamais
/// d’implémentation. Au jalon M3, brancher GRDB et Supabase se réduit donc à
/// changer la valeur par défaut ci-dessous, ou à l’écraser depuis la scène
/// principale, sans toucher à un seul écran. C’est aussi ce qui rend les
/// prévisualisations et les tests capables de fournir leur propre catalogue.
private struct CatalogRepositoryKey: EnvironmentKey {
    static let defaultValue: any CatalogRepository = DemoCatalogRepository()
}

extension EnvironmentValues {
    var catalogRepository: any CatalogRepository {
        get { self[CatalogRepositoryKey.self] }
        set { self[CatalogRepositoryKey.self] = newValue }
    }
}
