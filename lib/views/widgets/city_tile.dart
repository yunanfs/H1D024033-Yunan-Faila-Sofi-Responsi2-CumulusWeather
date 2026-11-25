import 'package:flutter/material.dart';

import '../../data/models/city_location.dart';
import 'soft_card.dart';

class CityTile extends StatelessWidget {
  const CityTile({
    super.key,
    required this.city,
    required this.trailing,
    required this.onTap,
    this.highlight = false,
  });

  final CityLocation city;
  final Widget trailing;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      highlight: highlight,
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.location_city_rounded, color: t.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(city.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(city.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.bodySmall),
            Text(city.coordinates,
                style: t.textTheme.labelSmall
                    ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ]),
        ),
        trailing,
      ]),
    );
  }
}
