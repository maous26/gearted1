// Login page fix for admin console
// This page uses the enhanced API service to fix the "Load failed" issue

import { useEffect } from 'react';

/**
 * This function updates the import statement in the login page to use the enhanced API service
 */
function fixLoginPage() {
  const fs = require('fs');
  const path = require('path');
  
  // Path to login page
  const loginPagePath = path.join(__dirname, 'src', 'app', 'login', 'page.tsx');
  
  // Read the file
  let content;
  try {
    content = fs.readFileSync(loginPagePath, 'utf8');
  } catch (err) {
    console.error(`Failed to read login page: ${err.message}`);
    return false;
  }
  
  // Update import statement
  const oldImport = "import { adminAPI, isAuthenticated } from '@/lib/api'";
  const newImport = "import { adminAPI, isAuthenticated } from '@/lib/enhanced-api'";
  
  if (content.includes(oldImport)) {
    content = content.replace(oldImport, newImport);
    
    try {
      fs.writeFileSync(loginPagePath, content, 'utf8');
      console.log('✅ Successfully updated login page to use enhanced API');
      return true;
    } catch (err) {
      console.error(`Failed to write login page: ${err.message}`);
      return false;
    }
  } else {
    console.log('⚠️ Could not find expected import statement in login page');
    return false;
  }
}

// Execute the fix
fixLoginPage();
