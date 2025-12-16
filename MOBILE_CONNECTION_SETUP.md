# Mobile Device Connection Setup

## Your Network Configuration
Based on your system, here are your available IP addresses:

- **Ethernet**: `10.65.0.68` (Primary connection)
- **USB Tethering**: `192.168.137.1` (Secondary)

## Backend Setup

### 1. Start Your AUTOHIVE Backend
Make sure your Laravel backend is running and accessible:

```bash
# In your AUTOHIVE backend directory
php artisan serve --host=0.0.0.0 --port=8000
```

**Important**: Use `--host=0.0.0.0` to make it accessible from other devices on the network.

### 2. Add Health Check Route (if not exists)
Add this to your Laravel `routes/api.php`:

```php
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'message' => 'AUTOHIVE API is running']);
});
```

### 3. Configure CORS (if needed)
In your Laravel backend `config/cors.php`:

```php
'allowed_origins' => ['*'],
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

## Mobile App Connection

### Connection Priority
The app will try these URLs in order:

1. `http://10.65.0.68:8000/api` (Your Ethernet IP)
2. `http://192.168.137.1:8000/api` (USB tethering)
3. `http://192.168.43.1:8000/api` (Mobile hotspot)
4. Other fallback URLs

### For Physical Device Testing

#### Option 1: Same WiFi Network
- Connect your mobile device to the same WiFi network as your computer
- The app will use: `http://10.65.0.68:8000/api`

#### Option 2: USB Tethering
- Enable USB tethering on your mobile device
- Connect via USB to your computer
- The app will use: `http://192.168.137.1:8000/api`

#### Option 3: Mobile Hotspot
- Create a mobile hotspot on your phone
- Connect your computer to the hotspot
- The app will use: `http://192.168.43.1:8000/api`

## Testing Connection

### 1. Test Backend Accessibility
From your computer, test if the backend is accessible:

```bash
# Test local access
curl http://localhost:8000/api/health

# Test network access
curl http://10.65.0.68:8000/api/health
```

### 2. Test from Mobile Device
- Open browser on your mobile device
- Navigate to: `http://10.65.0.68:8000/api/health`
- You should see: `{"status":"ok","message":"AUTOHIVE API is running"}`

## Firewall Configuration

### Windows Firewall
Allow Laravel through Windows Firewall:

1. Open Windows Defender Firewall
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change Settings" → "Allow another app"
4. Browse to your PHP executable or add port 8000

### Alternative: Disable Firewall Temporarily
```cmd
# Disable (for testing only)
netsh advfirewall set allprofiles state off

# Re-enable after testing
netsh advfirewall set allprofiles state on
```

## Troubleshooting

### If Connection Fails:

1. **Check Backend Status**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

2. **Verify Network Connectivity**
   - Ping your computer from mobile device
   - Ensure both devices are on same network

3. **Check Firewall Settings**
   - Temporarily disable firewall
   - Add exception for port 8000

4. **Try Different Connection Methods**
   - USB tethering
   - Mobile hotspot
   - Same WiFi network

### Common Issues:

- **"Connection refused"**: Backend not running or firewall blocking
- **"Network unreachable"**: Devices on different networks
- **"Timeout"**: Firewall or network configuration issue

## Current App Configuration

The Flutter app is configured to automatically detect and connect to your backend using these URLs. No manual configuration needed - just ensure your backend is running with `--host=0.0.0.0`.

## Success Indicators

✅ Backend running on `http://0.0.0.0:8000`
✅ Health endpoint returns JSON response
✅ Mobile device can access backend URL in browser
✅ Flutter app shows "Connected" status
✅ App loads apartments and user can login/register