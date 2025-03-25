import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

/// This script uploads the SQL schema to a Supabase project
/// It reads the SQL file, splits it into manageable chunks,
/// and executes each chunk using the Supabase exec_sql RPC function.
///
/// Usage:
/// dart upload_schema.dart

Future<void> main() async {
  print('Uploading schema to Supabase...');

  // Load environment variables
  await dotenv.dotenv.load(fileName: '.env');

  // Get Supabase credentials
  final supabaseUrl = dotenv.dotenv.env['SUPABASE_URL'] ??
      'https://wahoyhkhwvetpopnopqa.supabase.co';
  final supabaseKey = dotenv.dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhaG95aGtod3ZldHBvcG5vcHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0NjcwMTksImV4cCI6MjA1ODA0MzAxOX0.fG9eMAdGsFONMVKSIOt8QfkZPRBjrSsoKrxgCbgAbhY';

  // Create Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  // Check if RPC function exists
  try {
    final pingResponse = await supabase.rpc('ping');
    print('Connection to Supabase successful: $pingResponse');
  } catch (e) {
    print('Error connecting to Supabase: $e');
    print(
        'Make sure to create the "ping" function in Supabase SQL Editor first!');
    print('See ciftlik/docs/supabase_setup.md for instructions.');
    exit(1);
  }

  // Load the SQL schema
  String sqlSchemaPath = 'ciftlik/lib/database/schema.sql';
  if (!File(sqlSchemaPath).existsSync()) {
    print('Schema file not found at $sqlSchemaPath.');
    print('Trying alternative path...');

    sqlSchemaPath = 'lib/database/schema.sql';
    if (!File(sqlSchemaPath).existsSync()) {
      print('Schema file not found at $sqlSchemaPath either.');
      print('Please make sure the schema.sql file exists.');
      exit(1);
    }
  }

  final sqlSchema = File(sqlSchemaPath).readAsStringSync();
  print('Loaded SQL schema (${sqlSchema.length} characters)');

  // Split the SQL into chunks
  final List<String> sqlCommands = splitSqlCommands(sqlSchema);
  print('Split into ${sqlCommands.length} SQL commands');

  // Execute each SQL command
  int successCount = 0;
  int errorCount = 0;

  for (int i = 0; i < sqlCommands.length; i++) {
    final sql = sqlCommands[i].trim();
    if (sql.isEmpty) continue;

    try {
      print(
          'Executing command ${i + 1}/${sqlCommands.length} (${sql.length} chars)...');
      final response = await supabase.rpc('exec_sql', params: {'query': sql});

      final Map<String, dynamic> result = response;
      if (result['success'] == true) {
        successCount++;
        print('✓ Command ${i + 1} executed successfully');
      } else {
        errorCount++;
        print('✗ Command ${i + 1} failed: ${result['message']}');
      }
    } catch (e) {
      errorCount++;
      print('✗ Error executing command ${i + 1}: $e');
      // Print the first 100 chars of the SQL
      final preview = sql.length > 100 ? '${sql.substring(0, 100)}...' : sql;
      print('SQL preview: $preview');
    }

    // Brief pause to avoid overwhelming the server
    await Future.delayed(Duration(milliseconds: 500));
  }

  print(
      'Schema upload completed with $successCount successes and $errorCount errors');

  if (errorCount == 0) {
    print('All commands executed successfully!');
    print('You can now use the Supabase database with your application.');
  } else {
    print(
        'Some commands failed. You might need to check the Supabase SQL Editor for details.');
  }
}

List<String> splitSqlCommands(String sql) {
  // Split by semicolon but ensure we don't split inside functions or strings
  List<String> commands = [];
  StringBuffer currentCommand = StringBuffer();
  bool inFunction = false;

  for (var i = 0; i < sql.length; i++) {
    final char = sql[i];
    currentCommand.write(char);

    if (char == '\$' && i < sql.length - 1 && sql[i + 1] == '\$') {
      inFunction = !inFunction;
    }

    if (char == ';' && !inFunction) {
      commands.add(currentCommand.toString());
      currentCommand = StringBuffer();
    }
  }

  if (currentCommand.isNotEmpty) {
    commands.add(currentCommand.toString());
  }

  return commands;
}
