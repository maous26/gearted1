const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

// User model (simplified for script)
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  isAdmin: { type: Boolean, default: false },
  isEmailVerified: { type: Boolean, default: true },
  provider: { type: String, default: 'local' },
  rating: { type: Number, default: 0 },
  salesCount: { type: Number, default: 0 }
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);

async function createAdminUser() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.DB_URI);
    console.log('✅ Connected to MongoDB');

    // Check if admin user already exists
    const existingAdmin = await User.findOne({ email: 'admin@gearted.com' });
    
    if (existingAdmin) {
      console.log('❌ Admin user already exists');
      
      // Update to ensure isAdmin is true
      if (!existingAdmin.isAdmin) {
        existingAdmin.isAdmin = true;
        await existingAdmin.save();
        console.log('✅ Updated existing user to admin');
      }
      
      process.exit(0);
    }

    // Create new admin user
    const adminUser = new User({
      username: 'admin',
      email: 'admin@gearted.com',
      password: 'admin123',
      isAdmin: true,
      isEmailVerified: true,
      provider: 'local'
    });

    await adminUser.save();
    console.log('✅ Admin user created successfully');
    console.log('📧 Email: admin@gearted.com');
    console.log('🔐 Password: admin123');
    console.log('👑 Admin privileges: enabled');

  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('📝 Database connection closed');
    process.exit(0);
  }
}

createAdminUser();
