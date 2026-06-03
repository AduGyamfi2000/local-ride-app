# Backend Implementation Guide - RuralRide API

## Overview

This document provides backend developers with all the information needed to implement the RuralRide REST API endpoints to work with the Flutter mobile app.

## Architecture

The backend should follow this high-level architecture:

```
Mobile App (Flutter)
    ↓
    ↓ (REST API calls via Dio)
    ↓
API Gateway / Load Balancer
    ↓
    ├─ Authentication Service
    ├─ Ride Service
    ├─ Driver Service  
    ├─ Payment Service
    ├─ Rating Service
    └─ User Service
    ↓
    ├─ PostgreSQL (primary database)
    ├─ Redis (caching & sessions)
    └─ File Storage (profile pics, documents)
```

## Technology Stack Recommendations

- **Language**: Node.js/Express, Python/FastAPI, Go/Gin, or Java/Spring Boot
- **Database**: PostgreSQL (with PostGIS for geospatial queries)
- **Cache**: Redis
- **Message Queue**: RabbitMQ or Kafka (for events)
- **File Storage**: AWS S3 or GCS
- **Maps**: Google Maps API or Mapbox
- **Payments**: Stripe, PayPal, or mobile money provider API
- **Authentication**: JWT with refresh tokens
- **Real-time Updates**: WebSockets or Server-Sent Events (SSE)

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255) NOT NULL,
  role ENUM('user', 'driver', 'admin') NOT NULL,
  profile_pic_url VARCHAR(500),
  address TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Rides Table
```sql
CREATE TABLE rides (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  driver_id UUID REFERENCES users(id),
  vehicle_type VARCHAR(50),
  pickup_lat DECIMAL(10,8),
  pickup_lng DECIMAL(11,8),
  pickup_address TEXT,
  destination_lat DECIMAL(10,8),
  destination_lng DECIMAL(11,8),
  destination_address TEXT,
  passengers INT DEFAULT 1,
  status VARCHAR(50) DEFAULT 'searching',
  estimated_fare DECIMAL(10,2),
  actual_fare DECIMAL(10,2),
  distance_km DECIMAL(10,2),
  duration_minutes INT,
  requested_at TIMESTAMP,
  accepted_at TIMESTAMP,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_status CHECK (status IN ('searching', 'assigned', 'driver_en_route', 'arrived', 'in_progress', 'completed', 'cancelled')),
  INDEX idx_user_id (user_id),
  INDEX idx_driver_id (driver_id),
  INDEX idx_status (status)
);
```

### Drivers Table
```sql
CREATE TABLE drivers (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  vehicle_type VARCHAR(50),
  vehicle_plate VARCHAR(50) UNIQUE,
  vehicle_color VARCHAR(50),
  license_number VARCHAR(100) UNIQUE,
  license_expiry DATE,
  insurance_expiry DATE,
  status VARCHAR(50) DEFAULT 'offline',
  current_lat DECIMAL(10,8),
  current_lng DECIMAL(11,8),
  last_location_update TIMESTAMP,
  average_rating DECIMAL(3,2) DEFAULT 0.0,
  total_trips INT DEFAULT 0,
  total_earnings DECIMAL(12,2) DEFAULT 0.0,
  todays_earnings DECIMAL(12,2) DEFAULT 0.0,
  bank_account VARCHAR(255),
  background_check_status VARCHAR(50) DEFAULT 'pending',
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_status CHECK (status IN ('online', 'offline', 'busy')),
  INDEX idx_status (status),
  SPATIAL INDEX idx_location (current_lat, current_lng)
);
```

### Payments Table
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  ride_id UUID REFERENCES rides(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  transaction_id VARCHAR(255),
  reference_id VARCHAR(255),
  failure_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_ride_id (ride_id),
  INDEX idx_status (status)
);
```

### Ratings Table
```sql
CREATE TABLE ratings (
  id UUID PRIMARY KEY,
  ride_id UUID NOT NULL REFERENCES rides(id),
  rated_by UUID NOT NULL REFERENCES users(id),
  rated_to UUID NOT NULL REFERENCES users(id),
  score DECIMAL(3,2) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_score CHECK (score >= 1 AND score <= 5),
  INDEX idx_rated_to (rated_to),
  INDEX idx_ride_id (ride_id),
  UNIQUE KEY unique_rating_per_ride (ride_id, rated_by)
);
```

### Wallets Table
```sql
CREATE TABLE wallets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  balance DECIMAL(12,2) DEFAULT 0.0,
  phone_number VARCHAR(20),
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  wallet_id UUID REFERENCES wallets(id),
  amount DECIMAL(10,2) NOT NULL,
  type VARCHAR(50) NOT NULL,
  ride_id UUID REFERENCES rides(id),
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_type CHECK (type IN ('payment', 'refund', 'topup', 'withdrawal')),
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at)
);
```

## Key Implementation Details

### 1. Authentication Flow

```
1. User calls POST /auth/send-otp with phone number
2. Backend sends OTP to phone (SMS)
3. User calls POST /auth/verify-otp with phone + OTP + role
4. Backend verifies OTP, creates user if new, generates JWT token
5. Frontend stores token in SharedPreferences
6. All subsequent requests include Authorization: Bearer {token}
```

### 2. Ride Flow

```
1. User requests ride (POST /rides)
   - Store ride in DB with status='searching'
   - Return ride object to user
   
2. System finds nearby drivers (based on location)
   - Query drivers table with PostGIS: 
     WHERE ST_Distance(current_location, pickup_location) <= 10km
   - Order by distance
   
3. Assign to driver (POST /assignments)
   - Create assignment record
   - Send notification to driver
   - Update ride status to 'assigned'
   
4. Driver accepts (POST /drivers/{id}/rides/{id}/accept)
   - Update assignment status
   - Update ride status to 'driver_en_route'
   
5. Driver arrives and starts ride (POST /drivers/{id}/rides/{id}/start)
   - Update ride status to 'in_progress'
   
6. Complete ride (POST /drivers/{id}/rides/{id}/complete)
   - Calculate final fare
   - Deduct from user wallet (if wallet payment)
   - Add to driver earnings
   - Update ride status to 'completed'
   - Allow user to rate driver
```

### 3. Payment Processing

```
1. User makes payment (POST /payments)
   - Validate payment method
   - If wallet: deduct from wallet balance
   - If card: integrate with payment provider (Stripe)
   - If mobile money: integrate with provider API
   - Create payment record
   - Return payment object
   
2. Refund handling
   - POST /payments/{id}/refund
   - Return amount to wallet or original payment method
```

### 4. Real-time Driver Location

```
Option 1: Polling (simpler, less real-time)
- Client calls GET /drivers/{id}/location every 5 seconds
- Backend returns current lat/lng

Option 2: WebSockets (real-time)
- Client connects to WebSocket at /ws/rides/{id}
- Driver sends location updates via WebSocket
- Server broadcasts to all connected clients

Option 3: Server-Sent Events (middle ground)
- Client connects to GET /events/rides/{id} (with Accept: text/event-stream)
- Server streams location updates
```

### 5. Request Validation

All endpoints should validate:
```
- JWT token validity and expiration
- User exists in database
- User has permission to perform action
- Request data matches schema
- Rate limiting (100 req/min per user)
```

### 6. Error Handling

Return consistent error format:
```json
{
  "error": true,
  "code": "VALIDATION_ERROR",
  "message": "Email is required"
}
```

### 7. Logging & Monitoring

Log all:
- API requests/responses
- Database queries
- Payment transactions
- User actions
- Errors with full stack traces

Use structured logging (JSON format) for easy parsing.

## Sample Implementation (Node.js/Express)

```javascript
// POST /api/v1/auth/send-otp
app.post('/api/v1/auth/send-otp', async (req, res) => {
  const { phoneNumber } = req.body;
  
  // Validate
  if (!phoneNumber) return res.status(400).json({ error: true, code: 'VALIDATION_ERROR', message: 'Phone number required' });
  
  // Generate OTP
  const otp = Math.random().toString().slice(2, 8);
  
  // Send SMS (use Twilio, AWS SNS, etc.)
  await sendSMS(phoneNumber, `Your RuralRide OTP is: ${otp}`);
  
  // Store OTP in Redis (expires in 10 minutes)
  await redis.setex(`otp:${phoneNumber}`, 600, otp);
  
  res.json({ success: true, message: 'OTP sent' });
});

// POST /api/v1/auth/verify-otp
app.post('/api/v1/auth/verify-otp', async (req, res) => {
  const { phoneNumber, otp, role } = req.body;
  
  // Get OTP from Redis
  const storedOtp = await redis.get(`otp:${phoneNumber}`);
  if (!storedOtp || storedOtp !== otp) {
    return res.status(401).json({ error: true, message: 'Invalid OTP' });
  }
  
  // Find or create user
  let user = await User.findOne({ phone_number: phoneNumber });
  if (!user) {
    user = await User.create({
      phone_number: phoneNumber,
      role,
      name: 'RuralRide User',
      is_verified: true
    });
  }
  
  // Create JWT token
  const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
  
  // Delete OTP from Redis
  await redis.del(`otp:${phoneNumber}`);
  
  res.json({
    user: user,
    token: token
  });
});
```

## Testing Endpoints

Use Postman or curl:

```bash
# Send OTP
curl -X POST http://localhost:8080/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+233123456789"}'

# Verify OTP
curl -X POST http://localhost:8080/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+233123456789",
    "otp": "123456",
    "role": "user"
  }'

# Request Ride
curl -X POST http://localhost:8080/api/v1/rides \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_123",
    "vehicleType": "taxi",
    "pickup": {"lat": 5.6037, "lng": -0.1869, "address": "..."},
    "destination": {"lat": 5.5833, "lng": -0.2167, "address": "..."},
    "passengers": 1
  }'
```

## Deployment Checklist

- [ ] Database migrations run successfully
- [ ] Environment variables configured
- [ ] JWT secret stored securely
- [ ] Logging configured
- [ ] Error handling implemented
- [ ] Rate limiting configured
- [ ] CORS configured
- [ ] HTTPS enabled
- [ ] Database backups configured
- [ ] Monitoring & alerts setup
- [ ] Load testing completed
- [ ] Security audit passed

## Performance Considerations

- Index frequently queried columns (user_id, status, location)
- Use database views for complex queries
- Cache driver availability lists in Redis
- Implement query pagination (limit 50 results)
- Use database connection pooling
- Compress API responses
- Consider CDN for static assets
- Implement database query optimization

## Security Checklist

- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (use parameterized queries)
- [ ] XSS prevention (sanitize outputs)
- [ ] CSRF tokens if needed
- [ ] Rate limiting per user/IP
- [ ] JWT token expiration
- [ ] Password hashing (bcrypt)
- [ ] HTTPS/TLS enforcement
- [ ] API key rotation
- [ ] Secrets management (not in code)
- [ ] Access control per role
- [ ] Audit logging
