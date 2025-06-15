const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// User schema definition (simplified)
const userSchema = new mongoose.Schema({
  username: String,
  email: String,
  password: String,
  provider: String,
  isEmailVerified: Boolean,
  rating: Number,
  salesCount: Number
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

async function createAdminUser() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/gearted');
    console.log('Connected to MongoDB');
    
    // Check if admin user already exists
    const existingAdmin = await User.findOne({ email: 'admin@gearted.com' });
    if (existingAdmin) {
      console.log('Admin user already exists');
      process.exit(0);
    }
    
    // Create admin user
    const hashedPassword = await bcrypt.hash('admin123', 12);
    const adminUser = new User({
      username: 'admin',
      email: 'admin@gearted.com',
      password: hashedPassword,
      provider: 'local',
      isEmailVerified: true,
      rating: 5,
      salesCount: 0
    });
    
    await adminUser.save();
    console.log('Admin user created successfully');
    console.log('Email: admin@gearted.com');
    console.log('Password: admin123');
    
    mongoose.connection.close();
  } catch (error) {
    console.error('Error creating admin user:', error);
    process.exit(1);
  }
}

createAdminUser();
