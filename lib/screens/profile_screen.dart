import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Ahmet Yılmaz',
    'email': 'ahmet.yilmaz@example.com',
    'role': 'Çiftlik Yöneticisi',
    'profileImage': 'assets/images/profile_placeholder.png',
    'farmName': 'Yılmaz Çiftliği',
    'location': 'Ankara, Türkiye',
    'joinDate': '01.05.2023',
  };
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Show profile edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil düzenleme yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: OverflowHandler(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(theme),
              const SizedBox(height: 24),
              _buildProfileDetails(theme),
              const SizedBox(height: 24),
              _buildActionCards(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 80,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'],
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _userData['role'],
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(
                _userData['location'],
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kişisel Bilgiler',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'E-posta',
                _userData['email'],
                Icons.email,
                theme,
              ),
              const Divider(),
              _buildInfoItem(
                'Çiftlik Adı',
                _userData['farmName'],
                Icons.business,
                theme,
              ),
              const Divider(),
              _buildInfoItem(
                'Katılım Tarihi',
                _userData['joinDate'],
                Icons.calendar_today,
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hesap Yönetimi',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            'Şifre Değiştir',
            'Hesap güvenliğiniz için şifrenizi düzenli olarak değiştirin',
            Icons.lock,
            theme.colorScheme.primary,
            () {
              // Show password change dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şifre değiştirme yakında eklenecek')),
              );
            },
            theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Kullanıcı Tercihleri',
            'Bildirim, tema ve dil tercihlerinizi güncelleyin',
            Icons.settings,
            Colors.orange,
            () {
              // Navigate to preferences
              Get.toNamed('/settings');
            },
            theme,
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Çıkış Yap',
            'Hesabınızdan güvenli çıkış yapın',
            Icons.exit_to_app,
            Colors.red,
            () {
              // Show logout confirmation
              _showLogoutDialog();
            },
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yapılsın mı?'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Logout logic
              Get.offAllNamed('/login');
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
