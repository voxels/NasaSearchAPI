# NasaSearchAPI
Toy app that exposes the Nasa Search API

1. Which libraries you chose and why:
Beyond the data source from NASA, this app does not use 3rd party libraries because none are necessary to fetch and show the data.  

2. App architecture overview:
The app contains two view controllers, a view for each cell in the search view controller's collectionView, a model for each view controller, a networking class, and a collection of structs for encapsulating the response from the API.

3. Build and Run using XCode:  No extra steps are required besides changing the bundle identifier and team for running on device.

4. Other info:  There are no unit tests for this app.  Unit tests for this model would be focused on ensuring responses from the server are correct rather than ensuring the app's model functions as expected.  Writing unit tests, while a part of Workday's culture, would push the scope of the test beyond the time requested to complete the assignment.  Also of note: The app is intentionally built to handle both light and dark mode on iOS.


