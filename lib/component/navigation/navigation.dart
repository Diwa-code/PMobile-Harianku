import 'package:flutter/material.dart';

enum HariankuDestination { beranda, riwayat, cashflow, budget }

class HariankuBottomNavigationBar extends StatelessWidget {
  const HariankuBottomNavigationBar({
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.onAddTransaction,
    super.key,
  });

  final HariankuDestination selectedDestination;
  final ValueChanged<HariankuDestination> onDestinationSelected;
  final VoidCallback onAddTransaction;

  static const _primary = Color(0xFF253B80);
  static const _inactive = Color(0xFF8A90A0);
  static const _border = Color(0xFFECEEF3);

  static const _destinations = <_DestinationItem>[
    _DestinationItem(
      destination: HariankuDestination.beranda,
      label: 'Beranda',
      icon: Icons.home_rounded,
    ),
    _DestinationItem(
      destination: HariankuDestination.riwayat,
      label: 'Riwayat',
      icon: Icons.receipt_long_rounded,
    ),
    _DestinationItem(
      destination: HariankuDestination.cashflow,
      label: 'Cashflow',
      icon: Icons.bar_chart_rounded,
    ),
    _DestinationItem(
      destination: HariankuDestination.budget,
      label: 'Budget',
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08202432),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                for (final destination in _destinations.take(2))
                  Expanded(
                    child: _NavigationDestinationButton(
                      item: destination,
                      isSelected:
                          selectedDestination == destination.destination,
                      onTap: () =>
                          onDestinationSelected(destination.destination),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -8),
                      child: SizedBox.square(
                        dimension: 52,
                        child: Material(
                          color: _primary,
                          shape: const CircleBorder(),
                          elevation: 8,
                          shadowColor: _primary.withValues(alpha: 0.28),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onAddTransaction,
                            child: Tooltip(
                              message: 'Catat Transaksi',
                              child: Semantics(
                                button: true,
                                label: 'Catat Transaksi',
                                child: Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final destination in _destinations.skip(2))
                  Expanded(
                    child: _NavigationDestinationButton(
                      item: destination,
                      isSelected:
                          selectedDestination == destination.destination,
                      onTap: () =>
                          onDestinationSelected(destination.destination),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationButton extends StatelessWidget {
  const _NavigationDestinationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _DestinationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? HariankuBottomNavigationBar._primary
        : HariankuBottomNavigationBar._inactive;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: color),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 4 : 0,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: HariankuBottomNavigationBar._primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationItem {
  const _DestinationItem({
    required this.destination,
    required this.label,
    required this.icon,
  });

  final HariankuDestination destination;
  final String label;
  final IconData icon;
}
