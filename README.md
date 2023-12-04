# Currency Converter App

This is a simple currency converter app developed using Swift and the MVVM-C (Model-View-ViewModel-Coordinator) architecture. The app uses the RxSwift framework for reactive programming and XCTest for unit testing.

## Stack Used
- **Swift**
- **RxSwift**
- **MVVM-C (Model-View-ViewModel-Coordinator)**
- **XCTest**

## Features
- Currency conversion using real-time exchange rates.
- User-friendly interface with currency selection and amount input.
- Reverse button to easily switch between source and target currencies.

## Testing
Unit tests have been implemented using XCTest to ensure the correctness of various components within the app. More tests could come soon but I had limited time.

## Known Issues
The reachability feature, which determines internet availability, is not fully functional due to a problem with WiFi connection detection on the simulator. This issue is under investigation. 
Also I am a bit confused with the solution you have on the website connected with the endpoint fx-rates ( I implemented the same one ) . After investigation in dev tools I noticed that when I change the convertedTo value ( the bottom one ) you send it in -from- paramater but in reality it is TO value because it is at the bottom one. In my opinion the endpoint should have some optional parameters like amountTo or amountFrom, and the bottom currency should be sent as TO always. The backend would differate it by amountTo or amountFrom flag...

## How to Run the App
1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Run command pod install in terminal.
4. Build and run the app on the simulator.
