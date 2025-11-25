import Foundation

/// Centralized error messages for DVR
enum DVRError {
    
    // MARK: - SessionDataTask Errors
    
    /// Error when request is not found in cassette
    static let invalidRequest = "Invalid DVR request. No matching entry found in the cassette. Add the request to the cassette or enable recording and try again."
    
    /// Error when recording is disabled
    static let recordingDisabled = "DVR recording is disabled. Enable recording and try again."
    
    /// Error when task returns nil response
    static let nilResponse = "Recording failed. The task returned a nil response. Check the network stub or handler and try again."
    
    /// Error for unexpected failures
    static let unexpectedError = "Unexpected DVR error. Check logs for details and try again."
    
    // MARK: - Session Errors
    
    /// Error when cassettes directory cannot be created
    static let cannotCreateDirectory = "Cannot create cassettes directory. Check the path and write permissions, then try again."
    
    /// Error when cassette cannot be saved
    static let cannotSaveCassette = "Could not save cassette. Check the output path and write permissions, then try again."
    
    /// Success message when cassette is persisted
    static func cassetteSaved(at path: String) -> String {
        return "Cassette saved at \(path)."
    }
}

