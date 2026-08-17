const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const connectDB = require('./config/db');
const dns = require('node:dns/promises');
const bcrypt = require('bcryptjs');
const User = require('./models/User'); // Import User model for admin seeding

dns.setServers(['1.1.1.1', '8.8.8.8']);

// Load environment variables from .env
dotenv.config();

// Connect to MongoDB
connectDB();

// --- MASTER ADMIN SEEDER ---
async function seedAdmin() {
  try {
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@mediatracker.com';
    const existingAdmin = await User.findOne({ email: adminEmail });
    
    if (!existingAdmin) {
      const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD || 'superSecretMasterPassword123!', 10);
      await User.create({
        fullName: 'System Administrator',
        username: process.env.ADMIN_USERNAME || 'masteradmin',
        email: adminEmail,
        password: hashedPassword,
        bio: 'Master of the system.',
        profilePicture: '',
        role: 'admin' // Marks this user as an admin
      });
      console.log('Master Admin successfully seeded into the database.');
    } else {
      console.log('Master Admin already exists in the database.');
    }
  } catch (err) {
    console.error('Failed to seed admin:', err);
  }
}

seedAdmin(); // Run the seeder on startup
// ---------------------------

const app = express();

// Global Middlewares
app.use(cors()); // Allows your Flutter app to communicate with this API
app.use(express.json()); // Parses incoming JSON payloads

// Swagger Configuration
const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: {
      title: 'Media Tracker API Documentation',
      version: '1.0.0',
      description: 'Custom Node.js Backend for the Media Tracker Flutter Application',
    },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [{ bearerAuth: [] }],
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 5000}`,
      },
    ],
  },
  apis: ['./routes/*.js'], // Reads Swagger comments from your route files
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Mount Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/media', require('./routes/mediaRoutes'));
app.use('/api/activity', require('./routes/activityRoutes'));

// Root Ping Route
app.get('/', (req, res) => {
  res.send('Media Tracker Backend API is Running. Visit /api-docs for Swagger UI.');
});

// Standardized Global Error Handler
app.use((err, req, res, next) => {
  console.error('Server Exception:', err.message);
  res.status(err.status || 500).json({
    statusCode: err.status || 500,
    errorMessage: err.message || 'Internal Server Error',
    description: 'An unexpected exception occurred on the custom backend service.',
  });
});

// Start the Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});