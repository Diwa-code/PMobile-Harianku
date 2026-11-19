import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// HariankuAppBar — Reusable Header / AppBar Component
//
// Mendukung 3 varian tampilan:
//   • HariankuAppBar.simple    → AppBar standar dengan judul & ikon aksi opsional
//   • HariankuAppBar.dashboard → Header Beranda bergradien gelap dengan salam & avatar
//   • HariankuAppBar.inner     → AppBar untuk halaman dalam (back button + judul)
// ---------------------------------------------------------------------------

// ── Warna & konstanta dari panduan desain Harianku ──────────────────────────
class _HariankuColors {
  static const darkNavy = Color(0xFF0F172A);
  static const deepSlate = Color(0xFF1E293B);
  static const indigoBlue = Color(0xFF6366F1);
  static const electricBlue = Color(0xFF3B82F6);
  static const coolGray = Color(0xFF64748B);
  static const lightGray = Color(0xFFE2E8F0);
  static const surface = Color(0xFFFFFFFF);
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. HariankuAppBar — Widget utama (factory constructor pattern)
// ═══════════════════════════════════════════════════════════════════════════

class HariankuAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ── Simple variant ───────────────────────────────────────────────────────
  const HariankuAppBar.simple({
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = false,
    super.key,
  })  : _variant = _AppBarVariant.simple,
        userName = null,
        userAvatarUrl = null,
        onAvatarTap = null,
        onNotificationTap = null,
        hasNotification = false;

  // ── Dashboard variant ────────────────────────────────────────────────────
  const HariankuAppBar.dashboard({
    required this.userName,
    this.userAvatarUrl,
    this.onAvatarTap,
    this.onNotificationTap,
    this.hasNotification = false,
    super.key,
  })  : _variant = _AppBarVariant.dashboard,
        title = null,
        subtitle = null,
        actions = null,
        leading = null,
        automaticallyImplyLeading = false;

  // ── Inner page variant (back button) ─────────────────────────────────────
  const HariankuAppBar.inner({
    required this.title,
    this.subtitle,
    this.actions,
    super.key,
  })  : _variant = _AppBarVariant.inner,
        leading = null,
        automaticallyImplyLeading = true,
        userName = null,
        userAvatarUrl = null,
        onAvatarTap = null,
        onNotificationTap = null,
        hasNotification = false;

  // ── Shared fields ────────────────────────────────────────────────────────
  final _AppBarVariant _variant;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  // Dashboard-only fields
  final String? userName;
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  // ── PreferredSizeWidget ──────────────────────────────────────────────────
  @override
  Size get preferredSize => Size.fromHeight(
        _variant == _AppBarVariant.dashboard ? 80 : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _AppBarVariant.simple => _SimpleAppBar(
          title: title!,
          subtitle: subtitle,
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      _AppBarVariant.dashboard => _DashboardAppBar(
          userName: userName!,
          userAvatarUrl: userAvatarUrl,
          onAvatarTap: onAvatarTap,
          onNotificationTap: onNotificationTap,
          hasNotification: hasNotification,
        ),
      _AppBarVariant.inner => _InnerAppBar(
          title: title!,
          subtitle: subtitle,
          actions: actions,
        ),
    };
  }
}

enum _AppBarVariant { simple, dashboard, inner }

// ═══════════════════════════════════════════════════════════════════════════
// 2. _SimpleAppBar — Header standar dengan judul dan aksi opsional
// ═══════════════════════════════════════════════════════════════════════════

class _SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SimpleAppBar({
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _HariankuColors.surface,
      foregroundColor: _HariankuColors.darkNavy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _HariankuColors.lightGray,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleSpacing: leading != null ? 0 : 20,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _HariankuColors.darkNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _HariankuColors.coolGray,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _HariankuColors.darkNavy,
                letterSpacing: -0.3,
              ),
            ),
      actions: [
        ...?actions,
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: _HariankuColors.lightGray,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. _DashboardAppBar — Header Beranda dengan salam & avatar pengguna
// ═══════════════════════════════════════════════════════════════════════════

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashboardAppBar({
    required this.userName,
    this.userAvatarUrl,
    this.onAvatarTap,
    this.onNotificationTap,
    this.hasNotification = false,
  });

  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 🌤️';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_HariankuColors.darkNavy, _HariankuColors.deepSlate],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // ── Avatar ─────────────────────────────────────────────
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: _HariankuAvatar(
                      name: userName,
                      imageUrl: userAvatarUrl,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Salam & Nama ────────────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buildGreeting(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Tombol Notifikasi ───────────────────────────────────
                  _NotificationButton(
                    hasNotification: hasNotification,
                    onTap: onNotificationTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. _InnerAppBar — Header halaman dalam dengan back button
// ═══════════════════════════════════════════════════════════════════════════

class _InnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _InnerAppBar({
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _HariankuColors.surface,
      foregroundColor: _HariankuColors.darkNavy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _HariankuColors.lightGray,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: _HariankuColors.darkNavy,
          ),
        ),
        onPressed: () => Navigator.maybePop(context),
        tooltip: 'Kembali',
      ),
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _HariankuColors.darkNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _HariankuColors.coolGray,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _HariankuColors.darkNavy,
                letterSpacing: -0.3,
              ),
            ),
      actions: [
        ...?actions,
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _HariankuColors.lightGray),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. Sub-widget internal
// ═══════════════════════════════════════════════════════════════════════════

/// Avatar bulat dengan inisial nama sebagai fallback jika tidak ada gambar.
class _HariankuAvatar extends StatelessWidget {
  const _HariankuAvatar({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_HariankuColors.indigoBlue, _HariankuColors.electricBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => _AvatarInitials(initials: _initials),
              ),
            )
          : _AvatarInitials(initials: _initials),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Tombol notifikasi dengan badge dot merah opsional.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.hasNotification = false, this.onTap});

  final bool hasNotification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hasNotification ? 'Notifikasi (ada notifikasi baru)' : 'Notifikasi',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            if (hasNotification)
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. HariankuActionButton — Tombol aksi ikon reusable untuk AppBar actions
//
// Contoh penggunaan:
//   actions: [
//     HariankuActionButton(icon: Icons.search_rounded, onTap: () {}),
//     HariankuActionButton(icon: Icons.tune_rounded, onTap: () {}),
//   ]
// ═══════════════════════════════════════════════════════════════════════════

class HariankuActionButton extends StatelessWidget {
  const HariankuActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badgeCount,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _HariankuColors.darkNavy,
          ),
        ),
      ),
    );

    if (badgeCount != null && badgeCount! > 0) {
      button = Badge.count(
        count: badgeCount!,
        backgroundColor: _HariankuColors.indigoBlue,
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Semantics(button: true, label: tooltip, child: button);
  }
}
