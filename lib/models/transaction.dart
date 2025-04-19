class Transaction {
  final String id;
  final String title;
  final double unitPrice;
  final double amount;
  final DateTime date;
  final String type; // income or expense
  final int qty;
  final String? note; // bisa null jika kosong
  final String? category;



  Transaction({
    required this.id,
    required this.title,
    required this.unitPrice,
    required this.amount,
    required this.date,
    required this.type,
    required this.qty,
    this.note,
    this.category
  });
}
