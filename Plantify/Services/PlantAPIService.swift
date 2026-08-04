import Foundation

class PlantAPIService {

    private let apiKey = "4105c82f836f36083cc188861f8be3541abb3641"

    private let searchBaseURL = "https://open.plantbook.io/api/v1/plant/search"
    private let detailBaseURL = "https://open.plantbook.io/api/v1/plant/detail"

    // MARK: - SEARCH
    func searchPlant(named name: String) async throws -> Plant? {

        let alias = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "\(searchBaseURL)?alias=\(alias)"
        let url = URL(string: urlString)!

        print("\n================ SEARCH CALL ================")
        print("🔵 URL:", url.absoluteString)
        print("🔵 Header: Authorization: Token \(apiKey)")
        print("=============================================\n")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        print("🟢 STATUS:", status)
        print("🟢 RAW RESPONSE:\n", String(data: data, encoding: .utf8) ?? "NO DATA")

        // HTML error handling (502 etc.)
        if let text = String(data: data, encoding: .utf8),
           text.starts(with: "<") {
            print("⚠️ Plantbook API returned HTML instead of JSON.")
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(OPBSearchResponse.self, from: data)
            print("🟢 DECODED SEARCH RESULTS:", decoded.results.count)

            guard let first = decoded.results.first else {
                print("🟡 No results found.")
                return nil
            }

            print("🟢 FIRST PID:", first.pid)
            let detail = try await fetchDetail(pid: first.pid)

            // Load image
            let imageData = await loadImage(from: detail.image_url)

            // Convert to Plant
            return Plant.fromAPI(detail, imageData: imageData)

        } catch {
            print("🔴 DECODING ERROR:", error)
            return nil
        }
    }

    // MARK: - DETAIL
    private func fetchDetail(pid: String) async throws -> OPBPlantDetail {

        let urlString = "\(detailBaseURL)/\(pid)/"
        let url = URL(string: urlString)!

        print("\n================ DETAIL CALL ================")
        print("🟣 URL:", url.absoluteString)
        print("🟣 Header: Authorization: Token \(apiKey)")
        print("=============================================\n")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        print("🟣 STATUS:", status)
        print("🟣 RAW RESPONSE:\n", String(data: data, encoding: .utf8) ?? "NO DATA")

        // HTML error handling
        if let text = String(data: data, encoding: .utf8),
           text.starts(with: "<") {
            print("⚠️ Plantbook API returned HTML instead of JSON.")
            throw NSError(domain: "PlantAPI", code: 502)
        }

        do {
            let decoded = try JSONDecoder().decode(OPBPlantDetail.self, from: data)
            print("🟣 DECODED DETAIL OK")
            return decoded
        } catch {
            print("🔴 DECODING ERROR:", error)
            throw error
        }
    }

    // MARK: - IMAGE LOADING
    private func loadImage(from urlString: String?) async -> Data? {
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("⚠️ Could not load image:", error)
            return nil
        }
    }
}
