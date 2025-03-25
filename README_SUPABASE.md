# Çiftlik Yönetim - Supabase Setup Guide

This guide will help you set up and use Supabase with the Çiftlik Yönetim application.

## Initial Setup

1. Create an account at [Supabase](https://supabase.com/) if you don't have one
2. Create a new project in Supabase
3. Once your project is created, go to the "Settings" > "API" in the Supabase dashboard
4. Copy the "Project URL" and "anon/public" API key
5. Update your `.env` file with these values:

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

## Required Supabase Functions

The application requires certain PostgreSQL functions to be available in your Supabase project. 

### Setup the SQL Functions

1. Go to your Supabase dashboard
2. Click on "SQL Editor"
3. Create a new query
4. Paste the following SQL and execute it:

```sql
-- Create a function that allows executing SQL with proper permissions
CREATE OR REPLACE FUNCTION exec_sql(query text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
BEGIN
  EXECUTE query;
  result := '{"success": true, "message": "Query executed successfully"}'::jsonb;
  RETURN result;
EXCEPTION
  WHEN OTHERS THEN
    result := json_build_object(
      'success', false, 
      'message', 'Query execution failed: ' || SQLERRM,
      'error', SQLERRM,
      'context', 'Error occurred while executing: ' || query
    )::jsonb;
    RETURN result;
END;
$$;

-- Set appropriate permissions for the function
GRANT EXECUTE ON FUNCTION exec_sql TO authenticated;
GRANT EXECUTE ON FUNCTION exec_sql TO anon;
GRANT EXECUTE ON FUNCTION exec_sql TO service_role;

-- Create a simple ping function to test connection
CREATE OR REPLACE FUNCTION ping()
RETURNS text
LANGUAGE sql
AS $$
  SELECT 'pong'::text;
$$;

-- Set permissions for ping function
GRANT EXECUTE ON FUNCTION ping TO authenticated;
GRANT EXECUTE ON FUNCTION ping TO anon;
GRANT EXECUTE ON FUNCTION ping TO service_role;
```

## Setting up the Database Schema

### Method 1: Using the Upload Script

The `tools/upload_schema.dart` script can automatically upload the database schema to your Supabase project.

1. Make sure you've set up the required Supabase functions
2. Run the script:

```bash
cd [project_directory]
dart tools/upload_schema.dart
```

The script will connect to your Supabase project and execute the SQL commands from the schema file.

### Method 2: Manual Setup

If you prefer to set up the schema manually:

1. Open the `ciftlik/lib/database/schema.sql` file
2. Go to the Supabase SQL Editor
3. Create a new query
4. Copy and paste portions of the schema SQL and execute them
5. Some statements may need to be executed separately due to size limitations

## Using Supabase in the Application

The application is already configured to use Supabase as the primary data source. When the application starts:

1. It will try to connect to Supabase first
2. If Supabase is available, it will use it for all data operations
3. If Supabase is not available, it will fall back to the local database
4. You can manually switch between online and offline mode in the app settings

## Troubleshooting

### Connection Issues

- Make sure your Supabase URL and API key are correct in the `.env` file
- Check that the necessary functions (exec_sql, ping) are set up in your Supabase project
- Verify your internet connection
- Look at the application logs for specific error messages

### Database Errors

- If you encounter database errors, check the Supabase SQL Editor > "SQL Logs" for details
- Ensure the database schema has been completely and correctly applied
- Check for any database constraints or validation errors

### Schema Uploads Failing

- Upload the schema in smaller chunks
- Some SQL statements might need modification for Supabase
- Make sure the PostGIS extension is enabled in your Supabase project

## Additional Configuration

### Authentication

- If you want to use Supabase authentication, you'll need to configure the authentication providers in the Supabase dashboard
- Update the application code to use Supabase auth features

### Storage

- For storing files like animal images, you can create a bucket in Supabase Storage
- Configure the appropriate permissions for your bucket
- Update the application code to use Supabase storage for file operations

## Support

If you encounter any issues with Supabase integration, please reach out to the development team. 