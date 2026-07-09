import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuyumcu_flutter/app_colors.dart';
import 'package:kuyumcu_flutter/gold_price_service.dart';

class GoldTrackingScreen extends ConsumerStatefulWidget {
  const GoldTrackingScreen({super.key});

  @override
  ConsumerState<GoldTrackingScreen> createState() => _GoldTrackingScreenState();
}

class _GoldTrackingScreenState extends ConsumerState<GoldTrackingScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _selectedGoldType = 'gram-altin'; // Default selected key

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    final reversedInteger = buffer.toString().split('').reversed.join('');
    return '$reversedInteger,$decimalPart TL';
  }

  @override
  Widget build(BuildContext context) {
    final goldPricesAsync = ref.watch(goldPriceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: const Text(
          'Canlı Altın Takip',
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gold),
            onPressed: () {
              ref.invalidate(goldPriceProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Altın fiyatları güncelleniyor...'),
                  backgroundColor: AppColors.surfaceElevated,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: goldPricesAsync.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Fiyatlar yüklenirken bir hata oluştu.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tekrar Dene'),
                onPressed: () => ref.invalidate(goldPriceProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(GoldPriceData data) {
    // List of active gold types for display
    final List<Map<String, dynamic>> items = [
      {'key': 'gram-altin', 'name': 'Gram Altın (24 Ayar)', 'value': data.gramAltin},
      {'key': 'gram-has-altin', 'name': 'Has Altın (24 Ayar)', 'value': data.gramHasAltin},
      {'key': '22-ayar-bilezik', 'name': '22 Ayar Bilezik', 'value': data.ayar22},
      {'key': '18-ayar-altin', 'name': '18 Ayar Altın', 'value': data.ayar18},
      {'key': '14-ayar-altin', 'name': '14 Ayar Altın', 'value': data.ayar14},
      {'key': 'ceyrek-altin', 'name': 'Çeyrek Altın', 'value': data.ceyrekAltin},
      {'key': 'yarim-altin', 'name': 'Yarım Altın', 'value': data.yarimAltin},
      {'key': 'tam-altin', 'name': 'Tam Altın', 'value': data.tamAltin},
      {'key': 'cumhuriyet-altini', 'name': 'Cumhuriyet Altını', 'value': data.cumhuriyetAltini},
      {'key': 'ata-altin', 'name': 'Ata Altın', 'value': data.ataAltin},
    ];

    // Find current price for calculations
    final selectedType = items.firstWhere(
      (element) => element['key'] == _selectedGoldType,
      orElse: () => items.first,
    );
    final double unitPrice = selectedType['value'] as double;
    final double inputAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final double calculatedResult = unitPrice * inputAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Piyasa Fiyatları',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Güncelleme: ${data.updateDate.hour.toString().padLeft(2, '0')}:${data.updateDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Altın Hesaplayıcı Robot
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceElevated,
                  AppColors.surfaceElevated.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate_outlined, color: AppColors.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Altın Hesaplama Robotu',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Miktar Input
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Miktar (Gram / Adet)',
                          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                          floatingLabelStyle: const TextStyle(color: AppColors.gold),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.gold),
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tür Seçimi Dropdown
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                          color: Colors.black12,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.surfaceElevated,
                            value: _selectedGoldType,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.gold),
                            items: items.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['key'] as String,
                                child: Text(
                                  item['name'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedGoldType = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Hesaplanan Toplam Tutar',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatCurrency(calculatedResult),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Fiyat Kartları Listesi
          const Text(
            'Güncel Altın Fiyatları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final String name = item['name'] as String;
              final String key = item['key'] as String;
              final double val = item['value'] as double;

              final isSelectedInCalc = _selectedGoldType == key;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelectedInCalc
                        ? AppColors.gold.withOpacity(0.6)
                        : AppColors.divider.withOpacity(0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: AppColors.gold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Canlı Satış Fiyatı',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(val),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGoldType = key;
                              });
                              // Scroll up to calculator
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 300),
                                alignment: 0.5,
                              );
                            },
                            child: Text(
                              isSelectedInCalc ? 'Hesaplanıyor' : 'Hesapla',
                              style: TextStyle(
                                color: isSelectedInCalc ? AppColors.gold : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
