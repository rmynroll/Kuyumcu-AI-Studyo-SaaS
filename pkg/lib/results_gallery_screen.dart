import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_colors.dart';

class JewelryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String originalImageUrl;
  final String status; // 'completed', 'processing', 'failed'
  final DateTime date;
  final int qaScore;
  final bool isRefunded;

  JewelryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.originalImageUrl,
    required this.status,
    required this.date,
    this.qaScore = 100,
    this.isRefunded = false,
  });
}

class ResultsGalleryScreen extends ConsumerStatefulWidget {
  const ResultsGalleryScreen({super.key});

  @override
  ConsumerState<ResultsGalleryScreen> createState() => _ResultsGalleryScreenState();
}

class _ResultsGalleryScreenState extends ConsumerState<ResultsGalleryScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    // Premium Mock data for jewelry results showing Before (original) and After (AI Studio)
    final items = [
      JewelryItem(
        id: '1',
        title: 'Altın Yakut Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1598560917505-59a3ad559071?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        qaScore: 100,
        isRefunded: false,
      ),
      JewelryItem(
        id: '2',
        title: 'Elmas Baget Yüzük',
        originalImageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        qaScore: 82,
        isRefunded: true,
      ),
      JewelryItem(
        id: '3',
        title: 'Kuyumcu Gerdanlık',
        originalImageUrl: 'https://images.unsplash.com/photo-1611085583191-a3b1a3a355db?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=400&auto=format&fit=crop',
        status: 'completed',
        date: DateTime.now().subtract(const Duration(days: 1)),
        qaScore: 98,
        isRefunded: false,
      ),
      JewelryItem(
        id: '4',
        title: 'Safir Taş Kolye',
        originalImageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?q=80&w=400&auto=format&fit=crop',
        status: 'processing',
        date: DateTime.now(),
        qaScore: 0,
        isRefunded: false,
      ),
      JewelryItem(
        id: '5',
        title: 'Altın Zincir Bileklik',
        originalImageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        imageUrl: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?q=80&w=400&auto=format&fit=crop',
        status: 'failed',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _isSelectionMode
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Text(
                      '${_selectedItemIds.length} ürün seçildi',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = false;
                          _selectedItemIds.clear();
                        });
                      },
                      child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: _selectedItemIds.isEmpty
                          ? null
                          : () {
                              final selectedItems = items
                                  .where((item) => _selectedItemIds.contains(item.id))
                                  .toList();
                              _showWhatsAppExportDialog(context, selectedItems);
                            },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('WhatsApp Kataloğu Üret', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sonuçlarım',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Yapay zeka ile ürettiğiniz stüdyo görselleri.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _isSelectionMode ? Icons.check_circle : Icons.rule_rounded,
                      color: _isSelectionMode ? AppColors.gold : AppColors.textSecondary,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isSelectionMode) {
                          _isSelectionMode = false;
                          _selectedItemIds.clear();
                        } else {
                          _isSelectionMode = true;
                        }
                      });
                    },
                    tooltip: _isSelectionMode ? 'Seçimi Kapat' : 'Çoklu Seçim / WhatsApp',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // GRID VIEW
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = _selectedItemIds.contains(item.id);
                  return _JewelryGalleryCard(
                    item: item,
                    isSelectionMode: _isSelectionMode,
                    isSelected: isSelected,
                    onTap: () {
                      if (_isSelectionMode) {
                        if (item.status != 'completed') return;
                        setState(() {
                          if (isSelected) {
                            _selectedItemIds.remove(item.id);
                            if (_selectedItemIds.isEmpty) {
                              _isSelectionMode = false;
                            }
                          } else {
                            _selectedItemIds.add(item.id);
                          }
                        });
                      } else {
                        _showImageDetails(context, item);
                      }
                    },
                    onLongPress: () {
                      if (item.status != 'completed') return;
                      setState(() {
                        _isSelectionMode = true;
                        _selectedItemIds.add(item.id);
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWhatsAppExportDialog(BuildContext context, List<JewelryItem> selectedItems) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WhatsAppExportDialog(items: selectedItems),
    );
  }

  void _showImageDetails(BuildContext context, JewelryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                         _StatusBadge(item: item),
                        const Spacer(),
                        Text(
                          'ID: #${item.id}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (item.status == 'completed') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(
                            '/comparison?before=${Uri.encodeComponent(item.originalImageUrl)}'
                            '&after=${Uri.encodeComponent(item.imageUrl)}'
                            '&title=${Uri.encodeComponent(item.title)}',
                          );
                        },
                        icon: const Icon(Icons.compare_rounded, size: 20),
                        label: const Text('Önce / Sonra Kıyasla', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/results/${item.id}');
                        },
                        icon: const Icon(Icons.analytics_outlined, size: 20),
                        label: const Text('QA Sadakat Raporu', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(
                            '/premium/customer-mirror?title=${Uri.encodeComponent(item.title)}'
                            '&imageUrl=${Uri.encodeComponent(item.imageUrl)}',
                          );
                        },
                        icon: const Icon(Icons.camera_front_rounded, size: 20),
                        label: const Text('Müşteri Aynası (AR Paylaş)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showB2b2cShareSheet(context, item);
                        },
                        icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                        label: const Text('Müşteriye Özel Bağlantı (QR/WhatsApp)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.gold,
                          shadowColor: Colors.transparent,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(
                            '/premium/campaign?imageUrl=${Uri.encodeComponent(item.imageUrl)}',
                          );
                        },
                        icon: const Icon(Icons.card_giftcard_rounded, size: 20),
                        label: const Text('Kampanya Kartı Üret', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Kapat', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textOnGold,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: item.status == 'completed'
                                ? () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Görsel galeriye kaydedildi! (Simüle edildi)'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('İndir', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showB2b2cShareSheet(BuildContext context, JewelryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _B2b2cShareSheetContent(item: item);
      },
    );
  }
}

class _B2b2cShareSheetContent extends StatefulWidget {
  final JewelryItem item;

  const _B2b2cShareSheetContent({required this.item});

  @override
  State<_B2b2cShareSheetContent> createState() => _B2b2cShareSheetContentState();
}

class _B2b2cShareSheetContentState extends State<_B2b2cShareSheetContent> {
  bool _include3D = true;
  bool _includeSizer = true;
  bool _includePrice = true;

  @override
  Widget build(BuildContext context) {
    final sizerQuery = _includeSizer ? '1' : '0';
    final arQuery = _include3D ? '1' : '0';
    final priceQuery = _includePrice ? '14990' : '';
    final shareLink = 'kuyumcuaistudio.com/view/item-${widget.item.id}?ar=$arQuery&sizer=$sizerQuery&price=$priceQuery';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Müşteri Paylaşım Paneli',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Son müşterinizin kendi telefonunda etkileşimli olarak göreceği özellikleri seçin:',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // TOGGLES
          SwitchListTile.adaptive(
            title: const Text('3D Model / Döndürme Görünümü', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Müşteri ürünü sürükleyerek döndürebilir', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            value: _include3D,
            activeColor: AppColors.gold,
            onChanged: (val) => setState(() => _include3D = val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Yüzük Ölçer Modülü', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Müşteri telefon ekranından ölçü alabilir', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            value: _includeSizer,
            activeColor: AppColors.gold,
            onChanged: (val) => setState(() => _includeSizer = val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Fiyat Bilgisini Göster', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Katalogda 14.990 TL fiyatı gösterilir', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            value: _includePrice,
            activeColor: AppColors.gold,
            onChanged: (val) => setState(() => _includePrice = val),
          ),
          const SizedBox(height: 24),

          // QR CODE DISPLAY
          Center(
            child: Container(
              width: 130,
              height: 130,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(shareLink)}',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SelectableText(
              shareLink,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(height: 32),

          // ACTIONS Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      '/shared-product-view'
                      '?imageUrl=${Uri.encodeComponent(widget.item.imageUrl)}'
                      '&title=${Uri.encodeComponent(widget.item.title)}'
                      '&price=${_includePrice ? '14.990 TL' : ''}'
                      '&ar=${_include3D ? '1' : '0'}'
                      '&sizer=${_includeSizer ? '1' : '0'}',
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, color: AppColors.gold, size: 18),
                  label: const Text('Müşteri Ekranını Önizle', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF25D366),
                        content: Text('Bağlantı WhatsApp\'tan gönderildi!\nURL: $shareLink'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.white, size: 18),
                  label: const Text('WhatsApp ile Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JewelryGalleryCard extends StatelessWidget {
  const _JewelryGalleryCard({
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final JewelryItem item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.gold : AppColors.divider,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                      );
                    },
                  ),
                  if (isSelected)
                    Container(
                      color: AppColors.gold.withOpacity(0.12),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: isSelectionMode
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.gold : Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Icon(
                              isSelected ? Icons.check : Icons.add,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : _StatusBadge(item: item),
                  ),
                ],
              ),
            ),
            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppExportDialog extends StatefulWidget {
  final List<JewelryItem> items;

  const _WhatsAppExportDialog({required this.items});

  @override
  State<_WhatsAppExportDialog> createState() => _WhatsAppExportDialogState();
}

class _WhatsAppExportDialogState extends State<_WhatsAppExportDialog> {
  late final List<TextEditingController> _priceControllers;
  late final List<TextEditingController> _titleControllers;
  final TextEditingController _brandController = TextEditingController(text: 'Öz Kuyumculuk');
  String _selectedCurrency = 'TRY';
  bool _isExported = false;

  @override
  void initState() {
    super.initState();
    _priceControllers = widget.items.map((_) => TextEditingController(text: '15000')).toList();
    _titleControllers = widget.items.map((item) => TextEditingController(text: item.title)).toList();
  }

  @override
  void dispose() {
    for (var c in _priceControllers) {
      c.dispose();
    }
    for (var c in _titleControllers) {
      c.dispose();
    }
    _brandController.dispose();
    super.dispose();
  }

  String _generateCSV() {
    final buffer = StringBuffer();
    buffer.writeln('id,title,description,availability,condition,price,link,image_link,brand');
    for (int i = 0; i < widget.items.length; i++) {
      final id = 'SKU-${widget.items[i].id}';
      final title = _titleControllers[i].text.replaceAll(',', ' ');
      final priceVal = double.tryParse(_priceControllers[i].text) ?? 15000.0;
      final priceFormatted = '${priceVal.toStringAsFixed(2)} $_selectedCurrency';
      final desc = 'Kuyumcu AI Studio ile uretilmis ozel tasarim taki.'.replaceAll(',', ' ');
      final link = 'https://kuyumcu.ai/catalog/$id';
      final imageLink = widget.items[i].imageUrl;
      final brand = _brandController.text.replaceAll(',', ' ');
      buffer.writeln('$id,$title,$desc,in stock,new,$priceFormatted,$link,$imageLink,$brand');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.share_outlined, color: AppColors.gold, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isExported ? 'WhatsApp Kataloğu Hazır!' : 'WhatsApp Kataloğu Üret',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _isExported ? _buildSuccessView() : _buildConfigView(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                if (!_isExported)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        _isExported = true;
                      });
                    },
                    child: const Text('Kataloğu Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.textOnGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('WhatsApp Katalog CSV dosyası başarıyla indirildi!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('CSV Dosyasını İndir', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Secilen ${widget.items.length} urun icin katalog fiyat ve baslik bilgilerini girin:',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Products List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title field
                        SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _titleControllers[index],
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Urun Adi',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Price field
                        Row(
                          children: [
                            const Text('Fiyat:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _priceControllers[index],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                                  decoration: const InputDecoration(
                                    hintText: 'Orn: 15000',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Genel Katalog Ayarlari',
          style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Brand name
        const Text('Marka / Magaza Adi:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: _brandController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Currency
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Para Birimi:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  dropdownColor: AppColors.surfaceElevated,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem(value: 'TRY', child: Text('Turk Lirasi (TRY)')),
                    DropdownMenuItem(value: 'USD', child: Text('Amerikan Dolari (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCurrency = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final csvContent = _generateCSV();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Meta Commerce Manager uyumlu katalog basariyla uretildi.',
                  style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // CSV PREVIEW
        const Text(
          'CSV Icerik Onizlemesi',
          style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SelectableText(
                csvContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // HOW TO UPLOAD GUIDE
        const Text(
          'WhatsApp Business Yukleme Kilavuzu',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildGuideStep(
          '1',
          'CSV Dosyasini Indirin',
          'Asagidaki butona basarak olusturulan .csv dosyasini telefonunuza veya bilgisayariniza kaydedin.',
        ),
        const SizedBox(height: 12),
        _buildGuideStep(
          '2',
          'Meta Commerce Manager\'a Giris Yapin',
          'business.facebook.com/commerce adresine girip WhatsApp katalogunuzu secin.',
        ),
        const SizedBox(height: 12),
        _buildGuideStep(
          '3',
          'Veri Akisi (Data Feed) Ekleyin',
          'Veri Kaynaklari (Data Sources) sekmesinden "Urun Ekle" deyin ve "Veri Akisi (Data Feed)" secenegini secin.',
        ),
        const SizedBox(height: 12),
        _buildGuideStep(
          '4',
          'CSV Dosyasini Surukleyin',
          'Dosya yukleme alanina indirdiginiz .csv dosyasini yukleyin. Urunleriniz aninda WhatsApp katalogunuza islenecektir!',
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _isExported = false;
            });
          },
          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.gold),
          label: const Text('Bilgileri Duzenlemeye Don', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGuideStep(String number, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(color: AppColors.textOnGold, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final JewelryItem item;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (item.status) {
      case 'completed':
        if (item.isRefunded) {
          color = AppColors.error;
          icon = Icons.replay_rounded;
          label = 'İade Edildi (%${item.qaScore})';
        } else {
          color = AppColors.success;
          icon = Icons.check_circle;
          label = 'Uyum: %${item.qaScore}';
        }
        break;
      case 'processing':
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        label = 'İşleniyor';
        break;
      case 'failed':
      default:
        color = AppColors.error;
        icon = Icons.error_outline;
        label = 'Başarısız';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
