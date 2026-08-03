//
//  PlantAPIService.swift
//  Plantify
//
//  Created by Simon Groiss on 03.08.26.
//

import Foundation

struct PlantAPIService {
    private let apiKey = "sk-VmDm6a70dbe79f1af19130"

    func searchPlant(named name: String) async throws -> PlantAPIItem? {
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let url = URL(string: "https://perenual.com/api/species-list?key=\(apiKey)&q=\(query)")!

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PlantAPIResponse.self, from: data)

        if response.error != nil { return nil }
        if response.message != nil { return nil }

        return response.data?.first
    }
}
