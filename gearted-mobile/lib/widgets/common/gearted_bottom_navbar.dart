import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class GeartedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GeartedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, Icons.home, 'Accueil'),
              _buildNavItem(context, 1, Icons.search_outlined, Icons.search, 'Recherche'),
              _buildSellButton(context),
              _buildNavItem(context, 3, Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages'),
              _buildNavItem(context, 4, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, 
    int index, 
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? GeartedTheme.primaryBlue : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive ? GeartedTheme.primaryBlue : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellButton(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GeartedTheme.accentOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: GeartedTheme.accentOrange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Vendre',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: currentIndex == 2 
                    ? GeartedTheme.accentOrange 
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
