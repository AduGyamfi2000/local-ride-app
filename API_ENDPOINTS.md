# RuralRide REST API Endpoints

Base URL: `http://localhost:8080/api/v1`

## Authentication Endpoints

### Send OTP
- **POST** `/auth/send-otp`
- **Body**: `{ "phoneNumber": "+233..." }`
- **Response**: `{ "success": true, "message": "OTP sent" }`

### Verify OTP
- **POST** `/auth/verify-otp`
- **Body**: 
  ```json
  {
    "phoneNumber": "+233...",
    "otp": "123456",
    "role": "user|driver|admin"
  }
  ```
- **Response**:
  ```json
  {
    "user": {
      "id": "user_123",
      "phone": "+233...",
      "name": "John Doe",
      "role": "user",
      "profilePicUrl": null,
      "address": null,
      "isVerified": true,
      "createdAt": "2024-01-01T10:00:00Z"
    },
    "token": "jwt_token_here"
  }
  ```

### Get Current User
- **GET** `/auth/me`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ user object }`

### Logout
- **POST** `/auth/logout`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

---

## Ride Endpoints

### Request a Ride
- **POST** `/rides`
- **Headers**: `Authorization: Bearer {token}`
- **Body**:
  ```json
  {
    "userId": "user_123",
    "vehicleType": "taxi",
    "pickup": {"lat": 5.6037, "lng": -0.1869, "address": "Accra..."},
    "destination": {"lat": 5.5833, "lng": -0.2167, "address": "Kumasi..."},
    "passengers": 1,
    "status": "searching",
    "estimatedPrice": 50.0
  }
  ```
- **Response**: `{ ride object with id }`

### Get Ride Details
- **GET** `/rides/{rideId}`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ ride object }`

### Get User's Ride History
- **GET** `/users/{userId}/rides`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `[ { ride object }, ... ]`

### Get User's Active Ride
- **GET** `/users/{userId}/active-ride`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ ride object }` or `null`

### Update Ride Status
- **PUT** `/rides/{rideId}/status`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "status": "searching|assigned|driver_en_route|arrived|in_progress|completed|cancelled" }`
- **Response**: `{ ride object }`

### Complete Ride
- **PUT** `/rides/{rideId}/complete`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "actualFare": 55.0 }`
- **Response**: `{ ride object }`

### Cancel Ride
- **DELETE** `/rides/{rideId}`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

---

## Driver Endpoints

### Get Nearby Drivers
- **GET** `/drivers/nearby?lat=5.6037&lng=-0.1869&radius=10`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "drivers": [ { driver object }, ... ]
  }
  ```

### Get Driver Details
- **GET** `/drivers/{driverId}`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ driver object }`

### Update Driver Status
- **PUT** `/drivers/{driverId}/status`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "status": "online|offline|busy" }`
- **Response**: `{ "success": true }`

### Update Driver Location
- **PUT** `/drivers/{driverId}/location`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "latitude": 5.6037, "longitude": -0.1869 }`
- **Response**: `{ "success": true }`

### Create Assignment
- **POST** `/assignments`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "rideId": "ride_123", "driverId": "driver_456" }`
- **Response**: `{ assignment object }`

### Accept Ride
- **POST** `/drivers/{driverId}/rides/{rideId}/accept`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

### Reject Ride
- **POST** `/drivers/{driverId}/rides/{rideId}/reject`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

### Start Ride
- **POST** `/drivers/{driverId}/rides/{rideId}/start`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

### Complete Ride
- **POST** `/drivers/{driverId}/rides/{rideId}/complete`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

### Get Driver Earnings
- **GET** `/drivers/{driverId}/earnings`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "todayEarnings": 250.0,
    "weeklyEarnings": 1500.0,
    "monthlyEarnings": 5000.0,
    "totalEarnings": 15000.0,
    "totalTrips": 150
  }
  ```

### Get Driver Ratings
- **GET** `/drivers/{driverId}/ratings`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "averageRating": 4.8,
    "totalRatings": 120,
    "recentReviews": [ { rating object }, ... ]
  }
  ```

---

## Payment Endpoints

### Process Payment
- **POST** `/payments`
- **Headers**: `Authorization: Bearer {token}`
- **Body**:
  ```json
  {
    "userId": "user_123",
    "rideId": "ride_456",
    "amount": 55.0,
    "method": "wallet|card|momo"
  }
  ```
- **Response**: `{ payment object }`

### Get Wallet
- **GET** `/users/{userId}/wallet`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "userId": "user_123",
    "balance": 500.0,
    "phoneNumber": "+233...",
    "lastUpdated": "2024-01-01T10:00:00Z"
  }
  ```

### Add Funds
- **POST** `/users/{userId}/wallet/add-funds`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "amount": 100.0, "method": "card|momo|bank_transfer" }`
- **Response**:
  ```json
  {
    "balance": 600.0,
    "transactionId": "txn_123"
  }
  ```

### Get Transaction History
- **GET** `/users/{userId}/transactions`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  [
    {
      "id": "txn_123",
      "amount": 55.0,
      "type": "payment|refund|topup",
      "rideId": "ride_456",
      "status": "completed",
      "timestamp": "2024-01-01T10:00:00Z"
    }
  ]
  ```

### Refund Payment
- **POST** `/payments/{paymentId}/refund`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

---

## Rating Endpoints

### Submit Rating
- **POST** `/ratings`
- **Headers**: `Authorization: Bearer {token}`
- **Body**:
  ```json
  {
    "rideId": "ride_123",
    "ratedBy": "user_456",
    "ratedTo": "driver_789",
    "score": 4.5,
    "comment": "Great driver!"
  }
  ```
- **Response**: `{ rating object }`

### Get Driver Ratings
- **GET** `/drivers/{driverId}/ratings`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
  ```json
  {
    "averageRating": 4.8,
    "totalRatings": 120,
    "distribution": {
      "5": 100,
      "4": 15,
      "3": 3,
      "2": 1,
      "1": 1
    }
  }
  ```

### Get User's Rating History
- **GET** `/users/{userId}/ratings`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `[ { rating object }, ... ]`

### Get Ride Rating
- **GET** `/rides/{rideId}/rating`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ rating object }` or `null`

### Delete Rating
- **DELETE** `/ratings/{ratingId}`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `{ "success": true }`

---

## User Profile Endpoints

### Update Profile
- **PUT** `/users/{userId}/profile`
- **Headers**: `Authorization: Bearer {token}`
- **Body**: `{ "name": "John Doe", "address": "123 Main St" }`
- **Response**: `{ user object }`

---

## Error Response Format

All endpoints return errors in this format:

```json
{
  "error": true,
  "code": "ERROR_CODE",
  "message": "Human readable error message"
}
```

### Common Error Codes
- `UNAUTHORIZED` - Token missing or invalid (401)
- `FORBIDDEN` - User doesn't have permission (403)
- `NOT_FOUND` - Resource not found (404)
- `VALIDATION_ERROR` - Invalid request data (400)
- `SERVER_ERROR` - Internal server error (500)
- `NETWORK_ERROR` - Connection issues (503)

---

## Authentication

All endpoints (except `/auth/*`) require:
- **Header**: `Authorization: Bearer {jwt_token}`
- Tokens expire after 24 hours
- Use `/auth/refresh-token` to get a new token

---

## Rate Limiting

- 100 requests per minute per user
- 1000 requests per minute per IP

---

## Webhooks (Optional for real-time updates)

Subscribe to events:
- `ride.created`
- `ride.assigned`
- `ride.accepted`
- `ride.started`
- `ride.completed`
- `driver.location_updated`
- `payment.processed`
