/// API Configuration
/// 
/// For local development:
/// - Desktop/Web: Use http://localhost:3000/api
/// - Mobile: Use http://YOUR_COMPUTER_IP:3000/api (find IP with: ifconfig or ipconfig)
/// 
/// For production:
/// - Deploy backend to Heroku/Railway/Render
/// - Update baseUrl to your production backend URL

class ApiConfig {
  // ===== LOCAL DEVELOPMENT =====
  // For testing on same computer (web/desktop)
  static const String localhost = 'http://localhost:3000/api';
  
  // For testing on mobile device on same network
  // Replace with your computer's local IP address
  // Find it with: ifconfig (Mac/Linux) or ipconfig (Windows)
  // Example: 'http://192.168.1.100:3000/api'
  static const String localNetwork = 'http://192.168.1.2:3000/api'; // Your computer's IP
  
  // ===== PRODUCTION =====
  // Deploy backend to: Heroku, Railway, Render, etc.
  // Then update this URL with your deployed backend URL
  // IMPORTANT: Must be HTTPS (not HTTP) for Vercel deployment
  static const String production = 'https://tommye-favorless-geneva.ngrok-free.dev/api';
  
  // ===== CURRENT CONFIGURATION =====
  // Change this to switch between environments
  // For Vercel (HTTPS), you MUST use production backend with HTTPS
  static const bool useProduction = true; // Using ngrok HTTPS tunnel
  
  static String get baseUrl {
    if (useProduction) {
      return production;
    }
    // Use localNetwork for mobile device access
    // Use localhost for web browser on same computer
    // For now, using localNetwork so mobile can connect
    return localNetwork;
  }
}

