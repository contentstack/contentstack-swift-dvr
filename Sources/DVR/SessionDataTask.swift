import Foundation

final class SessionDataTask: URLSessionDataTask {

    // MARK: - Types

    typealias Completion = (Data?, Foundation.URLResponse?, NSError?) -> Void


    // MARK: - Properties

    weak var session: Session!
    let request: URLRequest
    let headersToCheck: [String]
    let completion: Completion?
    private let queue = DispatchQueue(label: "com.venmo.DVR.sessionDataTaskQueue", attributes: [])
    private var interaction: Interaction?

    override var response: Foundation.URLResponse? {
        return interaction?.response
    }

    override var currentRequest: URLRequest? {
        return request
    }


    // MARK: - Initializers

    init(session: Session, request: URLRequest, headersToCheck: [String] = [], completion: (Completion)? = nil) {
        self.session = session
        self.request = request
        self.headersToCheck = headersToCheck
        self.completion = completion
    }


    // MARK: - URLSessionTask

    override func cancel() {
        // Don't do anything
    }

    override func resume() {
        let cassette = session.cassette

        // Find interaction
        if let interaction = session.cassette?.interactionForRequest(request, headersToCheck: headersToCheck) {
            self.interaction = interaction
            // Forward completion
            if let completion = completion {
                queue.async {
                    completion(interaction.responseData, interaction.response, nil)
                }
            }
            session.finishTask(self, interaction: interaction, playback: true)
            return
        }

        if cassette != nil {
            fatalError(DVRError.invalidRequest)
        }

        // Cassette is missing. Record.
        if session.recordingEnabled == false {
            fatalError(DVRError.recordingDisabled)
        }

        let task = session.backingSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in

            //Ensure we have a response
            guard let response = response else {
                fatalError(DVRError.nilResponse)
            }

            guard let this = self else {
                fatalError(DVRError.unexpectedError)
            }

            // Still call the completion block so the user can chain requests while recording.
            this.queue.async {
                this.completion?(data, response, nil)
            }

            // Create interaction
            this.interaction = Interaction(request: this.request, response: response, responseData: data)
            this.session.finishTask(this, interaction: this.interaction!, playback: false)
        })
        task.resume()
    }
}
