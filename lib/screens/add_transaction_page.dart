import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionPage({super.key, this.existingTransaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _unitPrice = 0;
  String _type = 'income';
  DateTime _selectedDate = DateTime.now();
  int _qty = 1;
  String? _note;
  String? _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _title = tx.title;
      _unitPrice = tx.unitPrice;
      _qty = tx.qty;
      _selectedDate = tx.date;
      _type = tx.type;
      _note = tx.note;
      _selectedCategory = tx.category;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final double totalAmount = _unitPrice * _qty;

      if (widget.existingTransaction != null) {
        // Update mode
        final updatedTx = Transaction(
          id: widget.existingTransaction!.id,
          title: _title,
          unitPrice: _unitPrice,
          amount: totalAmount, // ini penting
          date: _selectedDate,
          type: _type,
          qty: _qty,
          note: _note,
          category: _selectedCategory,
        );

        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).updateTransaction(widget.existingTransaction!.id, updatedTx);
      } else {
        // Tambah baru
        final newTx = Transaction(
          id: const Uuid().v4(),
          title: _title,
          unitPrice: _unitPrice,
          amount: totalAmount, // ini juga
          date: _selectedDate,
          type: _type,
          qty: _qty,
          note: _note,
          category: _selectedCategory,
        );

        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addTransaction(newTx);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => _title = val!,
              ),
              TextFormField(
                initialValue: _unitPrice.toString(),
                decoration: const InputDecoration(labelText: 'Harga Satuan'),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || double.tryParse(val) == null
                            ? 'Masukkan angka'
                            : null,
                onSaved: (val) => _unitPrice = double.parse(val!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Kuantitas'),
                initialValue: _qty.toString(),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null ||
                                int.tryParse(val) == null ||
                                int.parse(val) <= 0
                            ? 'Masukkan kuantitas yang valid'
                            : null,
                onSaved: (val) => _qty = int.parse(val!),
              ),
              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
                onSaved: (val) => _note = val,
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Tanggal:'),
                  const SizedBox(width: 10),
                  Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Pengeluaran'),
                  ),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),

              // Kategori Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory!.isEmpty ? null : _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items:
                    categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.name,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
