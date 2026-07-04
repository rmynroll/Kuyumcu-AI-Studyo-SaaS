import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kuyumcu_flutter/app_colors.dart';
import 'package:kuyumcu_flutter/template.dart';


/// Şablon galerisindeki tek bir kart. Kuyumcu, metin okumak yerine
/// önizleme görselini görür; kredi maliyeti (varsa) küçük bir rozetle
/// üretime başlamadan önce netleşir — sürpriz maliyet olmaz.
class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key, required this.template, required this.onTap});

  final JewelryTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: template.previewImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(color: AppColors.surfaceElevated),
                    errorWidget: (context, _, __) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        template.creditBadgeLabel,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                template.label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}