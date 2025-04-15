-- ==========================================
-- SUPABASE DATABASE SCHEMA FOR REAL ESTATE APP
-- ==========================================

-- Profiles Table
-- Stores user profile information and links to the Supabase auth.users table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id), -- References Supabase auth user ID
  full_name TEXT NOT NULL, -- User's full name
  email TEXT UNIQUE NOT NULL, -- User's email address (must be unique)
  phone_number TEXT, -- User's phone number (optional)
  avatar_url TEXT, -- URL to user's profile image (optional)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- When profile was created
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- When profile was last updated
);

-- Properties Table
-- Stores real estate property listings
CREATE TABLE properties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- Unique identifier for property
  owner_id UUID REFERENCES profiles(id) NOT NULL, -- References the user who created this property
  title TEXT NOT NULL, -- Property title/name
  description TEXT NOT NULL, -- Detailed description of the property
  price DECIMAL(12,2) NOT NULL, -- Property price
  address TEXT NOT NULL, -- Street address
  city TEXT NOT NULL, -- City
  state TEXT NOT NULL, -- State/province
  country TEXT NOT NULL, -- Country
  zip_code TEXT, -- Postal/zip code
  property_type TEXT NOT NULL, -- Type (apartment, house, villa, etc.)
  bedrooms INTEGER NOT NULL, -- Number of bedrooms
  bathrooms DECIMAL(3,1) NOT NULL, -- Number of bathrooms (allows half baths like 2.5)
  area DECIMAL(10,2) NOT NULL, -- Area in square feet/meters
  is_featured BOOLEAN DEFAULT false, -- Whether property is featured
  status TEXT NOT NULL DEFAULT 'available', -- Status (available, sold, rented)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Property Images Table
-- Stores multiple images for each property
CREATE TABLE property_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE, -- When property is deleted, delete its images
  image_url TEXT NOT NULL, -- URL to the image
  is_primary BOOLEAN DEFAULT false, -- Whether this is the main image
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Property Amenities Table
-- Stores amenities associated with properties
CREATE TABLE property_amenities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  amenity_name TEXT NOT NULL, -- Name of amenity (pool, gym, etc.)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Favorites Table
-- Stores which users have favorited which properties
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, property_id) -- Prevents duplicate favorites
);

-- Contact Queries Table
-- Stores contact form submissions
CREATE TABLE contact_queries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  is_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- SECURITY POLICIES
-- ==========================================

-- Make sure each user can only view/edit their own profile
CREATE POLICY "Users can view their own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Properties are viewable by everyone but only editable by owners
CREATE POLICY "Anyone can view properties" 
  ON properties FOR SELECT 
  USING (true);

CREATE POLICY "Users can create their own properties" 
  ON properties FOR INSERT 
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own properties" 
  ON properties FOR UPDATE 
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own properties" 
  ON properties FOR DELETE 
  USING (auth.uid() = owner_id);

-- Contact queries are insertable by anyone but only viewable by admin
CREATE POLICY "Anyone can create contact queries" 
  ON contact_queries FOR INSERT 
  WITH CHECK (true);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_amenities ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_queries ENABLE ROW LEVEL SECURITY;

-- Add new policy for anonymous users to insert their own profile
CREATE POLICY "Users can insert their own profile" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id); 