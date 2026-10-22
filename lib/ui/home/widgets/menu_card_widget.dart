import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/menu_entity.dart';

class MenuCardWidget extends StatelessWidget {
  final MenuEntity menu;
  final VoidCallback onAdd;

  const MenuCardWidget({super.key, required this.menu, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuImage(url: menu.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkBrownText,
                  ),
                ),
                if (menu.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    menu.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatRupiah(menu.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: menu.isAvailable ? onAdd : null,
                      child: Text(menu.isAvailable ? 'Tambah' : 'Habis'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  final String? url;

  const _MenuImage({this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 84,
      height: 84,
      color: AppTheme.warmCreamBg,
      child: const Icon(Icons.ramen_dining, color: AppTheme.accentYellow),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (url == null || url!.isEmpty)
          ? placeholder
          : Image.network(
              url!,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}