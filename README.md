# Currency Exchange

This is a small app for doing currency exchange. After selecting the source and destination currencies, the app automatically performs currency exchange based on the amount entered in the input field. Some currency pairs are quite volatile, so the result is automatically updated every 10 seconds.

Exchange can be done in two ways: by entering the source amount, or by entering the desired amount. The web service doing the exchange supports both modes. Modes can be switched using the button.

## Implementation Notes

 - Implemented entirely using Swift and SwiftUI
   - Decided to go with SwiftUI instead of UIKit in order to experiment a bit
   - The deployment target is SDK 16 in order to maintain some compatibility
 - Makes use of Swift 6 and full concurrency checking
 - The project depends on my own libraries (SPAExtensions and SPAComponents), which contain reusable logic for doing network requests, displaying errors and progress indication:
   - `URLSession` Extension
   - `NSDecimalNumber` Extension
   - `EventNotifying` Protocol
   - `ProgressIndicating`
   - The libraries include some unit tests
 - Swift Package Manager used for dependency management
 - Unfortunately, the web service performing the currency exchange seems to work only via plain HTTP, so **I had to disable ATS**. A MITM attack would be quite easy

## Additional Notes

Basic validation on the amount input is done according to the device's locale. There are no restrictions on the size of the amount since different currencies can vary a lot in magnitude (e.g. 10 000 USD is more than 10 000 000 ARS). Applying any additional constraints on the amount is up to the web service.

The app attempts to parse error payloads received from the web service and displays the message to the user. In case there is no specific error payload, the app displays a more generic error message, depending on the HTTP status code or the type of network failure.

The list of currencies is built into the app. Ideally, a web service that provides the list of supported currencies (or currency pairs) would be used. I think the existing implementation enables integration with such service in a fairly straightforward way, by extending the `APIClient` and adding some additional calls inside the `CurrencyExchangeViewModel`.

The user interface is basic in terms of style given that there are no visual requirements, but I have made sure to have an animation when switching exchange modes. During network calls the progress indicator also animates, although briefly.

## Building and Running the Project

 - Open ExampleCurrenctExchange.xcodeproj and build the ExampleCurrenctExchange target using Xcode 16
 - Need SSH authentication configured with GitHub to fetch the dependencies
