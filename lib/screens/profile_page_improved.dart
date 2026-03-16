
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final String appDownloadUrl = "https://your-website.com"; // ضع رابط تحميل التطبيق هنا
  final String telegramUrl = "https://t.me/yourchannel";

  Future<void> _openTelegram() async {
    final uri = Uri.parse(telegramUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareApp() {
    Share.share("حمل تطبيق AsMovies من هنا:\n$appDownloadUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF05060A),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'البروفايل',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E17),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1B2133)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFE3C35A), Color(0xFFB98C10)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'AS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'AsMovies',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أفلام ومسلسلات في مكان واحد',
                    style:
                        TextStyle(color: Colors.white.withOpacity(.65), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _tile(
              icon: Icons.share_rounded,
              title: "مشاركة التطبيق",
              subtitle: "شارك التطبيق مع أصدقائك",
              onTap: _shareApp,
            ),

            _tile(
              icon: Icons.telegram_rounded,
              title: "قناة تيليجرام",
              subtitle: "تابعنا على تيليجرام",
              onTap: _openTelegram,
            ),

            _tile(
              icon: Icons.info_outline_rounded,
              title: "إصدار التطبيق",
              subtitle: "1.0.0",
            ),

            _tile(
              icon: Icons.privacy_tip_outlined,
              title: "سياسة الاستخدام",
              subtitle: "سيتم إضافتها لاحقاً",
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1B2133)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFD5B13E),
            child: Icon(icon, color: Colors.black),
          ),
          title: Text(title,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle,
              style: const TextStyle(color: Colors.white54)),
          trailing:
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
