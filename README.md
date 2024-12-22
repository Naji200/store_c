![WhatsApp Image 2024-12-22 à 18 49 42_106cafac](https://github.com/user-attachments/assets/434898e4-6fa5-41ff-919d-c9f797bfdb20)# naji_app


## Overview
This Flutter application provides a streamlined shopping cart system where users can add items to their cart, view item details, and manage their cart contents. If a user adds the same item multiple times, the app increments the item's quantity instead of duplicating it.

The app leverages Firebase for backend services like authentication and database management and is designed to provide a user-friendly interface with modern UI components.

---

## Features

### 1. User Profile Management
- Users can view and update their profile information such as birthday, address, postal code, and city.
- Profile data is securely fetched and updated in Firebase Realtime Database.
- Users can log out and return to the login screen.

### 2. Shopping Cart System
- Add items to the cart and increment their quantity if already present.
- Remove items from the cart using a simple delete button.
- View detailed information about each item, including price, size, and brand.
- Calculate and display the total cost of all items in the cart.

### 3. Firebase Integration
- **Authentication**: Manage user login and logout.
- **Realtime Database**: Store and retrieve user profiles and cart data.

---

## Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Authentication, Firebase Realtime Database
- **State Management**: Stateful widgets

---

## Installation

### Prerequisites
- Flutter SDK installed ([installation guide](https://docs.flutter.dev/get-started/install)).
- Firebase project set up with Authentication and Realtime Database enabled.

### Steps
1. Clone this repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd <project-folder>
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Configure Firebase:
   - Add the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to the respective directories.
   - Ensure Firebase Authentication and Realtime Database rules are set appropriately.
5. Run the app:
   ```bash
   flutter run
   ```

---

## Usage

### User Profile
1. Log in using valid Firebase credentials.
2. Update profile details such as birthday, address, postal code, and city.
3. Save changes, which will update the Firebase Realtime Database.

### Shopping Cart
1. Add items to the cart using a predefined method.
2. View cart contents, including item details and quantities.
3. Remove items from the cart as needed.
4. View the total cost at the bottom of the cart screen.

---

## Code Structure

### Key Files
- **`lib/screens/profile_page.dart`**: Handles user profile management.
- **`lib/screens/cart_screen.dart`**: Manages the shopping cart UI and functionality.
- **`lib/services/cart_service.dart`**: Contains logic for managing cart items.

### Folder Structure
```
lib/
|-- screens/       # UI for different screens (Profile, Cart, etc.)
|-- services/      # Logic for managing cart and other functionalities
|-- widgets/       # Custom reusable widgets (if applicable)
|-- main.dart      # Entry point of the app
```

---

## Future Enhancements
- **Search Functionality**: Allow users to search for products.
- **Checkout System**: Integrate payment gateways for a seamless checkout experience.
- **Push Notifications**: Notify users about promotions or cart updates.
- **Item Recommendations**: Suggest similar products based on cart contents.

---

## License
This project is licensed under the MIT License. You are free to use, modify, and distribute the code as per the license terms.

---

## Contact
For any queries or feedback, please contact:
- **Email**: najielalja2002@gmail.com
- **GitHub**: https://github.com/Naji200
![WhatsApp Image 2024-12-22 à 18 49 42_02990e58](https://github.com/user-attachments/assets/f087c40a-a4c3-478f-b27e-72b551302b68)

![WhatsApp Image 2024-12-22 à 18 49 42_45ac1ee7](https://github.com/user-attachments/assets/bc65116c-6631-4c09-9e7a-90cc3c53fd52)

![WhatsApp Image 2024-12-22 à 18 49 41_688fa745](https://github.com/user-attachments/assets/010790a2-1e89-4ada-924a-1eacf9d957e7)

![WhatsApp Image 2024-12-22 à 18 49 41_190f6650](https://github.com/user-attachments/assets/416645d7-bdd3-49da-a0ad-ca10b889335b)
![WhatsApp Image 2024-12-22 à 18 49 41_35c21e76](https://github.com/user-attachments/assets/4ada17f0-3e60-4916-8086-21b7e3cbe8bb)

![WhatsApp Image 2024-12-22 à 18 49 41_eb1245d1](https://github.com/user-attachments/assets/71a1d918-a067-4609-86b8-9e65f3c62fa9)




