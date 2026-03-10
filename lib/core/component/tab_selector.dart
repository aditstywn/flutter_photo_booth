import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/space.dart';

import '../style/color/colors_app.dart';

class TabItem {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;

  TabItem({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
  });
}

class ScrollableHorizontalTabSelector extends StatelessWidget {
  final List<TabItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? borderColor;
  final double? spacing;
  final EdgeInsets? margin;
  final double? iconSize;
  final double? fontSize;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsets? padding;
  final bool showLabel;
  final double? itemWidth;

  const ScrollableHorizontalTabSelector({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.spacing = 16,
    this.margin,
    this.iconSize = 28,
    this.fontSize = 14,
    this.borderRadius = 16,
    this.borderWidth = 2,
    this.padding,
    this.showLabel = true,
    this.itemWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    final defaultSelectedColor = selectedColor ?? ColorsApp.primary;
    final defaultUnselectedColor = unselectedColor ?? ColorsApp.white;
    final defaultBorderColor = borderColor ?? defaultSelectedColor;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 24),
      height: showLabel ? 85 : 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedId == item.id;
          final itemColor = item.color ?? defaultSelectedColor;

          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(
              right: index < items.length - 1 ? spacing! : 0,
            ),
            child: InkWell(
              onTap: () => onSelected(item.id),
              borderRadius: BorderRadius.circular(borderRadius!),
              child: Container(
                height: double.infinity,
                padding:
                    padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? itemColor : defaultUnselectedColor,
                  borderRadius: BorderRadius.circular(borderRadius!),
                  border: Border.all(
                    color: isSelected ? itemColor : defaultBorderColor,
                    width: borderWidth!,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showLabel) SpaceHeight(10),
                    Icon(
                      item.icon,
                      color: isSelected ? Colors.white : itemColor,
                      size: iconSize,
                    ),
                    if (showLabel) ...[
                      SizedBox(height: 4),
                      Expanded(
                        child: Center(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : itemColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
