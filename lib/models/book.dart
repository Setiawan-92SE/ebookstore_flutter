class Book {
  int? id;
  String judul;
  String penulis;
  String kategori;
  double harga;
  String deskripsi;
  String? coverUrl;
  int stok;
  int? sellerId;
  String status;

  Book({
    this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.harga,
    required this.deskripsi,
    this.coverUrl,
    this.stok = 0,
    this.sellerId,
    this.status = 'approved',
  });

  // Konversi dari Map (hasil query Cursor) ke objek Book
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      judul: map['judul'] ?? '',
      penulis: map['penulis'] ?? '',
      kategori: map['kategori'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      deskripsi: map['deskripsi'] ?? '',
      coverUrl: map['cover_url'],
      stok: map['stok'] ?? 0,
      sellerId: map['seller_id'],
      status: map['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'penulis': penulis,
      'kategori': kategori,
      'harga': harga,
      'deskripsi': deskripsi,
      'cover_url': coverUrl,
      'stok': stok,
      'seller_id': sellerId,
      'status': status,
    };
  }

  Book copyWith({
    int? id,
    String? judul,
    String? penulis,
    String? kategori,
    double? harga,
    String? deskripsi,
    String? coverUrl,
    int? stok,
    int? sellerId,
    String? status,
  }) {
    return Book(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      penulis: penulis ?? this.penulis,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      coverUrl: coverUrl ?? this.coverUrl,
      stok: stok ?? this.stok,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Book{id: $id, judul: $judul, penulis: $penulis, '
        'kategori: $kategori, harga: $harga, stok: $stok}';
  }
}
