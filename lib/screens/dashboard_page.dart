import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;
    final totalIncome = provider.income.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = provider.expense.fold(0.0, (sum, tx) => sum + tx.amount);
    final netIncome = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengelolaan Keuangan UMKM'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.green),
                          const SizedBox(height: 4),
                          const Text('Pemasukan',
                              style: TextStyle(color: Colors.green)),
                          Text(
                            currencyFormatter.format(totalIncome),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.red),
                          const SizedBox(height: 4),
                          const Text('Pengeluaran',
                              style: TextStyle(color: Colors.red)),
                          Text(
                            currencyFormatter.format(totalExpense),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Total Pendapatan Bersih'),
              trailing: Text(
                currencyFormatter.format(netIncome),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: netIncome >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Transaksi Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final tx = transactions[index];
                      return ListTile(
                        leading: Icon(
                          tx.type == 'income'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: tx.type == 'income' ? Colors.green : Colors.red,
                        ),
                        title: Text(tx.title),
                        subtitle: Text(DateFormat('dd MMMM yyyy').format(tx.date)),
                        trailing: Text(
                          currencyFormatter.format(tx.amount),
                          style: TextStyle(
                            color: tx.type == 'income' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
