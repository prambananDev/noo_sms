class Product {
  final int id;
  final String kode;
  final String nama;
  final String brand;
  final String? kemasan;
  final String? komposisi;
  final String fungsi;
  final String caraPakai;
  final String contohPenggunaan;
  final String gambar;
  final List<String> satuan;
  final String negaraPemasok;
  final String produsen;
  final String? produkGroup;
  final String produkCategory;
  final String produkSubCategory;
  final String produkStatus;
  final double beratBersih;
  final double panjang;
  final double lebar;
  final double tinggi;
  final String tipePenyimpanan;
  final String produkBU;
  final int waktuTenggang;
  final int umurSimpan;

  Product({
    required this.id,
    required this.kode,
    required this.nama,
    required this.brand,
    this.kemasan,
    this.komposisi,
    required this.fungsi,
    required this.caraPakai,
    required this.contohPenggunaan,
    required this.gambar,
    required this.satuan,
    required this.negaraPemasok,
    required this.produsen,
    this.produkGroup,
    required this.produkCategory,
    required this.produkSubCategory,
    required this.produkStatus,
    required this.beratBersih,
    required this.panjang,
    required this.lebar,
    required this.tinggi,
    required this.tipePenyimpanan,
    required this.produkBU,
    required this.waktuTenggang,
    required this.umurSimpan,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['Id'] ?? 0,
      kode: json['Kode'] ?? '',
      nama: json['Nama'] ?? '',
      brand: json['Brand'] ?? '',
      kemasan: json['Kemasan'],
      komposisi: json['Komposisi'],
      fungsi: json['Fungsi'] ?? '',
      caraPakai: json['CaraPakai'] ?? '',
      contohPenggunaan: json['ContohPenggunaan'] ?? '',
      gambar: json['Gambar'] ?? '',
      satuan: (json['Satuan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      negaraPemasok: json['NegaraPemasok'] ?? '',
      produsen: json['Produsen'] ?? '',
      produkGroup: json['ProdukGroup'],
      produkCategory: json['ProdukCategory'] ?? '',
      produkSubCategory: json['ProdukSubCategory'] ?? '',
      produkStatus: json['ProdukStatus'] ?? '',
      beratBersih: json['BeratBersih'] != null
          ? double.parse(json['BeratBersih'].toString())
          : 0.0,
      panjang: json['Panjang'] != null
          ? double.parse(json['Panjang'].toString())
          : 0.0,
      lebar:
          json['Lebar'] != null ? double.parse(json['Lebar'].toString()) : 0.0,
      tinggi: json['Tinggi'] != null
          ? double.parse(json['Tinggi'].toString())
          : 0.0,
      tipePenyimpanan: json['TipePenyimpanan'] ?? '',
      produkBU: json['ProdukBU'] ?? '',
      waktuTenggang: json['WaktuTenggang'] ?? 0,
      umurSimpan: json['UmurSimpan'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Kode': kode,
      'Nama': nama,
      'Brand': brand,
      'Kemasan': kemasan,
      'Komposisi': komposisi,
      'Fungsi': fungsi,
      'CaraPakai': caraPakai,
      'ContohPenggunaan': contohPenggunaan,
      'Gambar': gambar,
      'Satuan': satuan,
      'NegaraPemasok': negaraPemasok,
      'Produsen': produsen,
      'ProdukGroup': produkGroup,
      'ProdukCategory': produkCategory,
      'ProdukSubCategory': produkSubCategory,
      'ProdukStatus': produkStatus,
      'BeratBersih': beratBersih,
      'Panjang': panjang,
      'Lebar': lebar,
      'Tinggi': tinggi,
      'TipePenyimpanan': tipePenyimpanan,
      'ProdukBU': produkBU,
      'WaktuTenggang': waktuTenggang,
      'UmurSimpan': umurSimpan,
    };
  }
}
