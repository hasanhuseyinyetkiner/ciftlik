import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Observable states
  final RxBool _isConnected = false.obs;
  final RxBool _isOfflineMode = false.obs;
  final RxString _connectionStatus = 'initializing'.obs;

  // Public getters
  bool get isConnected => _isConnected.value;
  bool get isOfflineMode => _isOfflineMode.value;
  String get connectionStatus => _connectionStatus.value;

  // Constructor
  SupabaseService() {
    _initialize();
  }

  // Initialize Supabase connection
  Future<void> _initialize() async {
    try {
      // Attempt to connect by getting user
      final user = _client.auth.currentUser;
      _isConnected.value = true;
      _connectionStatus.value = 'connected';
      print(
          'Supabase connection established: ${user != null ? 'Authenticated' : 'Anonymous'}');
    } catch (e) {
      _isConnected.value = false;
      _connectionStatus.value = 'error';
      _isOfflineMode.value = true;
      print('Supabase connection error: $e');
    }
  }

  // Send test data to Supabase
  Future<bool> sendTestData() async {
    try {
      if (!isConnected) {
        print('Supabase not connected. Cannot send test data.');
        return false;
      }

      // Create a test object
      final testData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Test ${DateTime.now().toIso8601String()}',
        'value': DateTime.now().second,
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': true
      };

      // Send the test data to the test_data table
      final response =
          await _client.from('test_data').insert(testData).select();

      print('Test data sent successfully: $response');
      return true;
    } catch (e) {
      print('Error sending test data: $e');
      return false;
    }
  }

  // Generic fetch data method
  Future<List<Map<String, dynamic>>> fetchData(
    String table, {
    Map<String, dynamic>? equalTo,
    String? orderBy,
    bool descending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      if (!isConnected) return [];

      // Start with the table query
      dynamic queryBuilder = _client.from(table).select();

      // Apply filters if provided
      if (equalTo != null) {
        equalTo.forEach((key, value) {
          queryBuilder = queryBuilder.eq(key, value);
        });
      }

      // Apply ordering if provided
      if (orderBy != null) {
        queryBuilder = queryBuilder.order(orderBy, ascending: !descending);
      }

      // Apply pagination if provided
      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      if (offset != null) {
        queryBuilder = queryBuilder.range(offset, offset + (limit ?? 20) - 1);
      }

      // Execute the query
      final response = await queryBuilder;
      return response;
    } catch (e) {
      print('Error fetching data from $table: $e');
      return [];
    }
  }

  // Insert a record
  Future<Map<String, dynamic>?> insertData(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      if (!isConnected) return null;

      final response = await _client.from(table).insert(data).select().single();

      return response;
    } catch (e) {
      print('Error inserting data to $table: $e');
      return null;
    }
  }

  // Update a record
  Future<bool> updateData(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      if (!isConnected) return false;

      await _client.from(table).update(data).eq('id', id);

      return true;
    } catch (e) {
      print('Error updating data in $table: $e');
      return false;
    }
  }

  // Delete a record
  Future<bool> deleteData(
    String table,
    String id,
  ) async {
    try {
      if (!isConnected) return false;

      await _client.from(table).delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting data from $table: $e');
      return false;
    }
  }

  // Check connection to Supabase
  Future<bool> checkConnection() async {
    try {
      await _client.from('test_data').select('id').limit(1);
      _isConnected.value = true;
      _connectionStatus.value = 'connected';
      return true;
    } catch (e) {
      _isConnected.value = false;
      _connectionStatus.value = 'disconnected';
      return false;
    }
  }

  // Toggle offline mode manually
  void toggleOfflineMode(bool value) {
    _isOfflineMode.value = value;
    _connectionStatus.value =
        value ? 'offline' : (_isConnected.value ? 'connected' : 'disconnected');
  }
}
