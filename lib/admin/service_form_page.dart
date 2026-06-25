import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service_model.dart';
import '../src/file_image_helper.dart' as file_image_helper;

class ServiceFormPage extends StatefulWidget {
  final ServiceModel? service;

  const ServiceFormPage({this.service, super.key});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  late String _selectedIcon;
  late String _selectedImage;

  final List<String> _validIcons = ['water_drop', 'auto_fix_high', 'settings', 'shield'];

  final List<Map<String, String>> _categories = [
    {'key': 'water_drop', 'label': 'Wash', 'icon': '🚿'},
    {'key': 'auto_fix_high', 'label': 'Wax', 'icon': '✨'},
    {'key': 'settings', 'label': 'Engine', 'icon': '⚙️'},
    {'key': 'shield', 'label': 'Proteksi', 'icon': '🛡️'},
  ];

  final List<String> _validImages = [
    'assets/images/cucimotor.jpg',
    'assets/images/detailing.jpg',
    'assets/images/detailing engine.jpg',
    'assets/images/detailing full.jpg',
    'assets/images/polish body.jpg',
  ];

  static String _imageLabel(String path) {
    const labels = {
      'assets/images/cucimotor.jpg': 'Cuci Motor',
      'assets/images/detailing.jpg': 'Body Detail',
      'assets/images/detailing engine.jpg': 'Engine',
      'assets/images/detailing full.jpg': 'Full Detail',
      'assets/images/polish body.jpg': 'Polish',
    };
    return labels[path] ?? 'Image';
  }

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    final isEdit = service != null;

    _nameController = TextEditingController(text: isEdit ? service.name : '');
    _priceController = TextEditingController(text: isEdit ? service.price.toString() : '');

    _selectedIcon = (isEdit && _validIcons.contains(service.iconKey))
        ? service.iconKey
        : _validIcons.first;
    _selectedImage = (isEdit && (_validImages.contains(service.image) || service.image.isNotEmpty))
        ? service.image
        : _validImages.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget _buildPreviewImage(String path, {double? height, double? width, BoxFit? fit}) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
      );
    } else {
      return file_image_helper.fileImage(
        path,
        height: height,
        width: width,
        fit: fit,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0D1B2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Edit Layanan" : "Tambah Layanan",
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Header
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPreviewImage(
                    _selectedImage,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      "Pratinjau Gambar Cover",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form inputs container
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Layanan
                  const Text(
                    "Nama Layanan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Contoh: Wash & Wax Premium",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Harga
                  const Text(
                    "Harga",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      decoration: InputDecoration(
                        prefixText: "Rp ",
                        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        hintText: "Contoh: 15000",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kategori
                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _categories.map((cat) {
                      final isSelected = cat['key'] == _selectedIcon;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = cat['key']!;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D1B2A) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                if (!isSelected)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  cat['icon']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['label']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.amber : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Pilih Cover (Background Image)
                  const Text(
                    "Pilih Gambar Cover",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _validImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Gallery Upload Card
                          final isCustomSelected = !_validImages.contains(_selectedImage);
                          return GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isCustomSelected ? const Color(0xFF0D1B2A).withOpacity(0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCustomSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade300,
                                  width: isCustomSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: isCustomSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade600,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isCustomSelected ? "Gambar Terpilih" : "Upload File",
                                    style: TextStyle(
                                      color: isCustomSelected ? const Color(0xFF0D1B2A) : Colors.grey.shade600,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final imgPath = _validImages[index - 1];
                        final isSelected = imgPath == _selectedImage;
                        final label = _imageLabel(imgPath);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = imgPath;
                            });
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0D1B2A) : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    imgPath,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    color: Colors.black38,
                                  ),
                                  Center(
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Color(0xFF0D1B2A),
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        foregroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF0D1B2A).withOpacity(0.3),
                      ),
                      onPressed: _saveService,
                      child: const Text(
                        "Simpan Layanan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveService() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lengkapi Nama dan Harga layanan!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = int.tryParse(priceText) ?? 0;
    final isEdit = widget.service != null;

    if (isEdit) {
      final service = widget.service!;
      service.name = name;
      service.price = price;
      service.iconKey = _selectedIcon;
      service.image = _selectedImage;
    } else {
      final newService = ServiceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        price: price,
        image: _selectedImage,
        iconKey: _selectedIcon,
        description: "",
      );
      ServiceData.services.add(newService);
    }

    await ServiceData.saveServices();

    if (mounted) {
      Navigator.pop(context, true); // Returns true to trigger refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? "Layanan berhasil diperbarui!" : "Layanan berhasil ditambahkan!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
