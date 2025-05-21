import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kas_umkm/providers/category_provider.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_page.dart';
import 'transaction_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedCategory = 'Semua';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    // gabungkan dengan 'Semua'
    final categoryOptions = ['Semua', ...categories.map((e) => e.name)];

    // Filtering
    List<Transaction> filtered =
        transactions.where((tx) {
          final matchCategory =
              selectedCategory == 'Semua' ||
              (tx.category?.toLowerCase().trim() ==
                  selectedCategory.toLowerCase().trim());
          final matchDate =
              selectedDate == null ||
              DateFormat('yyyy-MM-dd').format(tx.date) ==
                  DateFormat('yyyy-MM-dd').format(selectedDate!);
          return matchCategory && matchDate;
        }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    // Grouping by date
    Map<String, List<Transaction>> groupedTx = {};
    for (var tx in filtered) {
      String dateKey = DateFormat('dd MMMM yyyy').format(tx.date);
      groupedTx.putIfAbsent(dateKey, () => []).add(tx);
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600),), 
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        ),
      body: Column(
        children: [
          // Filter UI
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items:
                            categoryOptions.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                controller: TextEditingController(
                                  text:
                                      selectedDate != null
                                          ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(selectedDate!)
                                          : '',
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                          if (selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List Transaksi
          Expanded(
            child:
                filtered.isEmpty
                    ? const Center(child: Text('Tidak ada transaksi.'))
                    : ListView.builder(
                      itemCount: groupedTx.length,
                      itemBuilder: (context, index) {
                        final date = groupedTx.keys.elementAt(index);
                        final txList = groupedTx[date]!;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ...txList.map((tx) {
                                  final amount = currencyFormatter.format(
                                    tx.amount,
                                  );
                                  final isIncome = tx.type == 'income';

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          isIncome
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      child: Icon(
                                        isIncome
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color:
                                            isIncome
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    title: Text(
                                      tx.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text('${tx.category} • $amount'),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => AddTransactionPage(
                                                    existingTransaction: tx,
                                                  ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          Provider.of<TransactionProvider>(
                                            context,
                                            listen: false,
                                          ).deleteTransaction(tx.id);
                                        }
                                      },
                                      itemBuilder:
                                          (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Hapus'),
                                            ),
                                          ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  TransactionDetailPage(tx: tx),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
