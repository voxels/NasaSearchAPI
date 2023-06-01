# NasaSearchAPI
Toy app that exposes the Nasa Search API

1. Which libraries you chose and why:
Beyond the data source from NASA, this app does not use 3rd party libraries because none are necessary to fetch and show the images.  

2. App architecture overview:
The app contains a view controller, view controller model, networking class, structs for encapsulating the response from the API, and a view for each cell in the view controller's collectionView.

3. Build and Run using XCode:  No extra steps are required besides changing the bundle identifier and team for running on device.

4. Unit tests:  There are no unit tests for this app because the guidance was to take a half a day to complete the assignment and adding unit tests would push the scope beyond what was requested.  Almost all of the model is just networking code, so unit tests would be focused on ensuring responses from the server are correct rather than ensuring the app's model functions as expected, which seems out of scope for this assignment.


