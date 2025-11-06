class Bill {
  final String id;
  final String customerId;
  final String month; // '2025-11'
  final double totalQuantity;
  final double amount;
  final bool paid;
  final String? paymentScreenshotUrl;

  Bill({required this.id, required this.customerId, required this.month, required this.totalQuantity, required this.amount, this.paid = false, this.paymentScreenshotUrl});
  
  Map<String, dynamic> toMap() => {
    'customerId': customerId,
    'month': month,
    'totalQuantity': totalQuantity,
    'amount': amount,
    'paid': paid,
    'paymentScreenshotUrl': paymentScreenshotUrl,
    'generatedAt': FieldValue.serverTimestamp(),
  };

  factory Bill.fromMap(String id, Map<String, dynamic> map) => Bill(
    id: id,
    customerId: map['customerId'],
    month: map['month'],
    totalQuantity: (map['totalQuantity'] as num).toDouble(),
    amount: (map['amount'] as num).toDouble(),
    paid: map['paid'] ?? false,
    paymentScreenshotUrl: map['paymentScreenshotUrl'],
  );
}
