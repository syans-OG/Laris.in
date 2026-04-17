import 'package:equatable/equatable.dart';
import 'transaction_item_entity.dart';

class TransactionEntity extends Equatable {
  final int id;
  final String invoiceNo;
  final double total;
  final double discount;
  final double tax;
  final String paymentMethod;
  final double paidAmount;
  final double changeAmount;
  final int cashierId;
  final DateTime createdAt;
  final List<TransactionItemEntity>? items;
  final int isPrinted;
  final String? printedAt;
  final String? printMethod;
  final String? shareMethod;

  const TransactionEntity({
    required this.id,
    required this.invoiceNo,
    required this.total,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.paymentMethod,
    required this.paidAmount,
    required this.changeAmount,
    required this.cashierId,
    required this.createdAt,
    this.items,
    this.isPrinted = 0,
    this.printedAt,
    this.printMethod,
    this.shareMethod,
  });

  TransactionEntity copyWith({
    int? id,
    String? invoiceNo,
    double? total,
    double? discount,
    double? tax,
    String? paymentMethod,
    double? paidAmount,
    double? changeAmount,
    int? cashierId,
    DateTime? createdAt,
    List<TransactionItemEntity>? items,
    int? isPrinted,
    String? printedAt,
    String? printMethod,
    String? shareMethod,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      cashierId: cashierId ?? this.cashierId,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      isPrinted: isPrinted ?? this.isPrinted,
      printedAt: printedAt ?? this.printedAt,
      printMethod: printMethod ?? this.printMethod,
      shareMethod: shareMethod ?? this.shareMethod,
    );
  }

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as int,
      invoiceNo: json['invoice_no'] as String,
      total: (json['total'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paidAmount: (json['paid_amount'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      cashierId: json['cashier_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: null, // Populated separately via repository join
      isPrinted: json['is_printed'] as int? ?? 0,
      printedAt: json['printed_at'] as String?,
      printMethod: json['print_method'] as String?,
      shareMethod: json['share_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'total': total,
      'discount': discount,
      'tax': tax,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'cashier_id': cashierId,
      'created_at': createdAt.toIso8601String(),
      'is_printed': isPrinted,
      'printed_at': printedAt,
      'print_method': printMethod,
      'share_method': shareMethod,
    };
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNo,
        total,
        discount,
        tax,
        paymentMethod,
        paidAmount,
        changeAmount,
        cashierId,
        createdAt,
        items,
        isPrinted,
        printedAt,
        printMethod,
        shareMethod,
      ];
}
