class Asset {
  final int id;
  final String jenisAssetNama;
  final String serialNumber;
  final String merk;
  final String kapasitas;
  final String dayaListrik;
  final String lokasiGudang;
  final double? latitude;
  final double? longitude;
  final bool status;
  final String statusName;
  final String? customer;

  Asset({
    required this.id,
    required this.jenisAssetNama,
    required this.serialNumber,
    required this.merk,
    required this.kapasitas,
    required this.dayaListrik,
    required this.lokasiGudang,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.statusName,
    required this.customer,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['Id'],
      jenisAssetNama: json['JenisAssetNama'] ?? '',
      serialNumber: json['SerialNumber'] ?? '',
      merk: json['Merk'] ?? '',
      kapasitas: json['Kapasitas'] ?? '',
      dayaListrik: json['DayaListrik'] ?? '',
      lokasiGudang: json['LokasiGudang'] ?? '',
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      status: json['Status'],
      statusName: json['StatusName'] ?? '',
      customer: json['Customer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'JenisAssetNama': jenisAssetNama,
      'SerialNumber': serialNumber,
      'Merk': merk,
      'Kapasitas': kapasitas,
      'DayaListrik': dayaListrik,
      'LokasiGudang': lokasiGudang,
      'Latitude': latitude,
      'Longitude': longitude,
      'Status': status,
      'StatusName': statusName,
      'Customer': customer,
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }
}

class AssetResponse {
  final PaginationInfo pagination;
  final List<Asset> items;

  AssetResponse({
    required this.pagination,
    required this.items,
  });

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    return AssetResponse(
      pagination: PaginationInfo.fromJson(json),
      items: List<Asset>.from(
        json['items'].map((item) => Asset.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class AssetHistory {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final List<Item> items;

  AssetHistory({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory AssetHistory.fromJson(Map<String, dynamic> json) {
    return AssetHistory(
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Item {
  final int? id;
  final String? assetId;
  final String? customerId;
  final String? tanggalPeminjaman;
  final String? tanggalPengembalian;
  final String? tanggalDiterima;
  final String? fotoDiterima;
  final String? keterangan;
  final int? status;
  final String? statusName;
  final String? custtable;
  final String? asset;

  Item({
    this.id,
    this.assetId,
    this.customerId,
    this.tanggalPeminjaman,
    this.tanggalPengembalian,
    this.tanggalDiterima,
    this.fotoDiterima,
    this.keterangan,
    this.status,
    this.statusName,
    this.custtable,
    this.asset,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['Id'],
      assetId: json['AssetId'],
      customerId: json['CustomerId'],
      tanggalPeminjaman: json['TanggalPeminjaman'],
      tanggalPengembalian: json['TanggalPengembalian'],
      tanggalDiterima: json['TanggalDiterima'],
      fotoDiterima: json['FotoDiterima'],
      keterangan: json['Keterangan'],
      status: json['Status'],
      statusName: json['StatusName'],
      custtable: json['custtable'],
      asset: json['Asset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AssetId': assetId,
      'CustomerId': customerId,
      'TanggalPeminjaman': tanggalPeminjaman,
      'TanggalPengembalian': tanggalPengembalian,
      'TanggalDiterima': tanggalDiterima,
      'FotoDiterima': fotoDiterima,
      'Keterangan': keterangan,
      'Status': status,
      'StatusName': statusName,
      'custtable': custtable,
      'Asset': asset,
    };
  }
}

class Customer {
  final String accountNum;
  final String custNameAlias;

  Customer({
    required this.accountNum,
    required this.custNameAlias,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      accountNum: json['ACCOUNTNUM'],
      custNameAlias: json['CUSTNAME_ALIAS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ACCOUNTNUM': accountNum,
      'CUSTNAME_ALIAS': custNameAlias,
    };
  }
}

class AssetDetail {
  final int? id;
  final String? assetId;
  final String? customerId;
  final String? tanggalPeminjaman;
  final String? tanggalPengembalian;
  final String? tanggalDiterima;
  final String? fotoDiterima;
  final String? keterangan;
  final int? status;
  final String? statusName;
  final String? custtable;
  final String? asset;

  AssetDetail({
    this.id,
    this.assetId,
    this.customerId,
    this.tanggalPeminjaman,
    this.tanggalPengembalian,
    this.tanggalDiterima,
    this.fotoDiterima,
    this.keterangan,
    this.status,
    this.statusName,
    this.custtable,
    this.asset,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      id: json['Id'],
      assetId: json['AssetId'],
      customerId: json['CustomerId'],
      tanggalPeminjaman: json['TanggalPeminjaman'],
      tanggalPengembalian: json['TanggalPengembalian'],
      tanggalDiterima: json['TanggalDiterima'],
      fotoDiterima: json['FotoDiterima'],
      keterangan: json['Keterangan'],
      status: json['Status'],
      statusName: json['StatusName'],
      custtable: json['custtable'],
      asset: json['Asset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AssetId': assetId,
      'CustomerId': customerId,
      'TanggalPeminjaman': tanggalPeminjaman,
      'TanggalPengembalian': tanggalPengembalian,
      'TanggalDiterima': tanggalDiterima,
      'FotoDiterima': fotoDiterima,
      'Keterangan': keterangan,
      'Status': status,
      'StatusName': statusName,
      'custtable': custtable,
      'Asset': asset,
    };
  }
}

class AssetAvail {
  final String asset;
  final int id;

  AssetAvail({
    required this.asset,
    required this.id,
  });

  factory AssetAvail.fromJson(Map<String, dynamic> json) {
    return AssetAvail(
      asset: json['asset'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'id': id,
    };
  }
}

class AssetLoan {
  final String customerId;
  final int assetId;
  final String tanggalPeminjaman;
  final String keterangan;

  AssetLoan({
    required this.customerId,
    required this.assetId,
    required this.tanggalPeminjaman,
    required this.keterangan,
  });

  Map<String, dynamic> toJson() {
    return {
      'CustomerId': customerId,
      'AssetId': assetId,
      'TanggalPeminjaman': tanggalPeminjaman,
      'Keterangan': keterangan,
    };
  }

  factory AssetLoan.fromJson(Map<String, dynamic> json) {
    return AssetLoan(
      customerId: json['CustomerId'],
      assetId: json['AssetId'],
      tanggalPeminjaman: json['TanggalPeminjaman'],
      keterangan: json['Keterangan'],
    );
  }
}

class AssetReturn {
  final int assetId;
  final String tanggalPengembalian;

  AssetReturn({
    required this.assetId,
    required this.tanggalPengembalian,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': assetId,
      'TanggalPengembalian': tanggalPengembalian,
    };
  }

  factory AssetReturn.fromJson(Map<String, dynamic> json) {
    return AssetReturn(
      assetId: json['id'],
      tanggalPengembalian: json['TanggalPengembalian'],
    );
  }
}
