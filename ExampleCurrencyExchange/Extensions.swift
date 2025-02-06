//
//  Extensions.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import SPAExtensions

public extension URLSession {
    
    @MainActor
    func perform<ResultType>(_ request: URLRequest,
                             checkResponse: ((HTTPURLResponse) -> ())? = nil,
                             parseResponse: @escaping(Data) throws->(ResultType),
                             parseErrorResponse: @escaping(Data) throws -> CommonError = { _ in throw CommonError.custom("No error parsing") }) async ->
        Result<ResultType, CommonError> {
        
        do {
            let rawResponse = try await self.data(for: request)
            
            if let response = rawResponse.1 as? HTTPURLResponse {
                checkResponse?(response)
                
                if response.httpStatus == .success {
                    do {
                        let data = try parseResponse(rawResponse.0)
                        return .success(data)
                    }
                    catch let e as CommonError {
//                        request.httpDebugLog(e.description)
                        return .failure(.api("Could not parse API response"))
                    }
                }
                else if response.statusCode == 401 {
                    return .failure(try parseErrorResponse(rawResponse.0) ?!? .session(.missingToken))
                }
                else if response.statusCode == 403 {
                    return .failure(try parseErrorResponse(rawResponse.0) ?!? .api("No authorization for this resource"))
                }
                else if response.statusCode == 404 {
                    return .failure(try parseErrorResponse(rawResponse.0) ?!? .api("Resource not found"))
                }
                else if response.httpStatus == .clientError {
//                    request.httpDebugLog("Error \(response.statusCode)")
                    return .failure(try parseErrorResponse(rawResponse.0) ?!? .client(.invalidInput))
                }
//                request.httpDebugLog(String(format: "Returned HTTP status code %@", String(describing: response.statusCode)))
            }
            return .failure(.server(.internal))
        }
        catch let e {
//            request.httpDebugLog(e.localizedDescription)
            return  .failure(e.kind ?? .custom(e.localizedDescription))
        }
    }
}


extension NSDecimalNumber {
    
    private static let formatter = NumberFormatter()
    
    func toString(_ locale: Locale = .current) -> String {
        Self.formatter.locale = locale
        Self.formatter.numberStyle = .decimal
        Self.formatter.maximumFractionDigits = 2
        Self.formatter.minimumFractionDigits = 2
        return Self.formatter.string(from: self) ?? ""
    }
    
    static func from(string: String, locale: Locale = .current) -> NSDecimalNumber? {
        Self.formatter.locale = locale
        Self.formatter.numberStyle = .decimal
        Self.formatter.maximumFractionDigits = 2
        Self.formatter.minimumFractionDigits = 2
        if let number = Self.formatter.number(from: string) {
            return NSDecimalNumber.init(decimal: number.decimalValue)
        }
        return nil
    }
}
