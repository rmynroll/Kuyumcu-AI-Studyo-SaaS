import 'package:flutter/material.dart';
import 'app_colors.dart';

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController(text: 'Kuyumcu Sarraf A.Ş.');
  final _brandController = TextEditingController(text: 'Öz Kuyumculuk');
  final _yearController = TextEditingController(text: '1998');
  final _emailController = TextEditingController(text: 'iletisim@kuyumcusarraf.com');
  final _phoneController = TextEditingController(text: '+90 (212) 555 1234');
  final _addressController = TextEditingController(
    text: 'Kapalıçarşı, Kalpakçılar Cd. No: 45, Fatih / İstanbul',
  );
  final _taxOfficeController = TextEditingController(text: 'Fatih V.D.');
  final _taxNumberController = TextEditingController(text: '4829302194');
  final _mersisController = TextEditingController(text: '0482930219400012');
  final _kepController = TextEditingController(text: 'kuyumcusarraf@hs01.kep.tr');
  final _certTemplateController = TextEditingController(
    text: 'Bu mücevher Öz Kuyumculuk garantisi altında 18 ayar altından üretilmiştir.',
  );

  String _selectedCurrency = 'TRY';

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxOfficeController.dispose();
    _taxNumberController.dispose();
    _mersisController.dispose();
    _kepController.dispose();
    _certTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Firma Detayları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Firma & Kurumsal Ayarlar',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Faturalandırma, katalog ve mücevher sertifikalarında yer alacak kurumsal bilgilerinizi düzenleyin.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    // SECTION 1: TEMEL BİLGİLER
                    _buildSectionCard(
                      title: 'Temel Firma Bilgileri',
                      icon: Icons.storefront_outlined,
                      children: [
                        _buildTextField(
                          label: 'Resmi Ticari Unvan',
                          controller: _titleController,
                          validator: (v) => v!.isEmpty ? 'Gerekli alan' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Mağaza / Marka Adı',
                          controller: _brandController,
                          validator: (v) => v!.isEmpty ? 'Gerekli alan' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Kuruluş Yılı',
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: İLETİŞİM & LOKASYON
                    _buildSectionCard(
                      title: 'İletişim & Lokasyon',
                      icon: Icons.location_on_outlined,
                      children: [
                        _buildTextField(
                          label: 'E-posta Adresi',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'Gerekli alan' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Telefon Numarası',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Merkez Adres',
                          controller: _addressController,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: RESMİ & VERGİ BİLGİLERİ
                    _buildSectionCard(
                      title: 'Fatura & Resmi Bilgiler',
                      icon: Icons.receipt_long_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Vergi Dairesi',
                                controller: _taxOfficeController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                label: 'Vergi Numarası',
                                controller: _taxNumberController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'MERSİS Numarası',
                          controller: _mersisController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'KEP Adresi',
                          controller: _kepController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SECTION 4: SERTİFİKA & PARA BİRİMİ
                    _buildSectionCard(
                      title: 'Sertifika & Tercihler',
                      icon: Icons.workspace_premium_outlined,
                      children: [
                        const Text(
                          'Varsayılan Para Birimi',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCurrency,
                              dropdownColor: AppColors.surfaceElevated,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'TRY', child: Text('Türk Lirası (TRY)')),
                                DropdownMenuItem(value: 'USD', child: Text('Amerikan Doları (USD)')),
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
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Otomatik Sertifika Garanti Metni',
                          controller: _certTemplateController,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // SAVE BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text('Firma detayları başarıyla güncellendi!'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
