//
//  ChatResponse.swift
//  PromptBuddy
//
//  Created by Me on 5/7/2025.
//

import Foundation

public struct ChatResponse: Decodable {

    public let id: String
    public let error: ChatError?
    public let output: [ResponseMessage]?

    public var message: String {
        var content = ""

        output?.forEach {
            switch $0.type {
            case "reasoning":
                if $0.summary?.isEmpty == false {
                    content += "Reasoning:\n"
                    $0.summary?.forEach {
                        content += "[\($0.type)]:\n\($0.text ?? "")"
                    }
                    content += "\n"
                }
            case "message":
                $0.content?.forEach {
                    content += "\($0.text ?? "")\n"
                }
            default:
                break
            }
        }
        return content
    }
}

public struct ResponseMessage: Decodable {
    public let type: String
    public let status: String?
    public let content: [ResponseContent]?
    public let summary: [ResponseContent]?
}

public struct ResponseContent: Decodable {
    public let type: String
    public let text: String?
}

public struct ChatRequest: Codable {
    public let model: String
    public let input: [ChatMessage]
    public let previous_response_id: String?
    public let tools: [ChatTool]?

    public init(model: String,
         input: [ChatMessage],
         previous_response_id: String? = nil,
         tools: [ChatTool]? = nil) {
        self.model = model
        self.input = input
        self.tools = tools
        self.previous_response_id = previous_response_id
    }

}

public struct ChatTool: Codable {
    public let type: String
}

public struct ChatMessage: Codable {
    public let role: String // "developer", "user", or "assistant"
    public let content: [ChatMessageContent]

    public init(developer: String) {
        role = "developer"
        content = [ChatMessageContent(text: developer)]
    }

    public init(user message: String) {
        role = "user"
        self.content = [ChatMessageContent(text: message)]
    }

    public init(user content: [ChatMessageContent]) {
        role = "user"
        self.content = content
    }
}

public struct ChatMessageContent: Codable {
    public let type: String
    public var text: String?
    public var image_url: String?

    public init(image: PlatformImage) {
        type = "input_image"
        if let pngData = image.data {
            image_url = "data:image/png;base64,\(pngData.base64EncodedString())"
        }
    }

    public init(text: String) {
        type = "input_text"
        self.text = text
        self.image_url = nil
    }
}

public struct ModelResponse: Decodable {
    public let data: [ModelResponseItem]
    public let error: ChatError?
}

public struct ModelResponseItem: Decodable {
    public let id: String
    public let created: Int
}

public struct ChatError: Decodable {
    public let message: String
}

public struct ErrorResponse: Decodable {
    public let error: ChatError
    
    public var apiError: GPTAPIError {
        .error(error.message)
    }
}

public enum GPTAPIError: Error {
    case error(String)
}
