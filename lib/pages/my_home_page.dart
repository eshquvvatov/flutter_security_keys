import 'package:flutter/material.dart';
import 'package:secur_keys/secure_service/secure_service.dart';

import 'models/storage_item.dart';


class MyHomePage extends StatefulWidget {


  const MyHomePage({Key? key,}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StorageService _storageService = StorageService();
  late List<StorageItem> _items;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    initList();
  }

  void initList() async {
    _items = await _storageService.readAllSecureData();
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Secure Home page"
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => showDialog(
                context: context, builder: (_) => const SearchKeyValueDialog()),
          )
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _items.isEmpty
            ? const Text("Add data in secure storage to display here.")
            : ListView.builder(
            itemCount: _items.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (_, index) {
              return Dismissible(
                key: Key(_items[index].toString()),
                child: VaultCard(item: _items[index]),
                onDismissed: (direction) async {
                  await _storageService
                      .deleteSecureData(_items[index])
                      .then((value) => _items.removeAt(index));
                  initList();
                },
              );
            }),
      ),
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final StorageItem? newItem = await showDialog<StorageItem>(
                        context: context, builder: (_) => AddDataDialog());
                    if (newItem != null) {
                      _storageService.writeSecureData(newItem).then((value) {
                        setState(() {
                          _loading = true;
                        });
                        initList();
                      });
                    }
                  },
                  child: const Text("Add Data"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () async {
                    _storageService
                        .deleteAllSecureData()
                        .then((value) => initList());
                  },
                  child: const Text("Delete All Data"),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

}

class AddDataDialog extends StatelessWidget {
  AddDataDialog({Key? key}) : super(key: key);

  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ref.watch(storageServiceProvider.notifier);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _keyController,
              decoration: textFieldDecoration(hintText: "Enter Key"),
            ),
            TextFormField(
              controller: _valueController,
              decoration: textFieldDecoration(hintText: "Enter Value"),
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      final StorageItem storageItem = StorageItem(
                          _keyController.text, _valueController.text);
                      Navigator.of(context).pop(storageItem);
                    },
                    child: const Text('Secure')))
          ],
        ),
      ),
    );
  }
}

class EditDataDialog extends StatefulWidget {
  final StorageItem item;

  const EditDataDialog({Key? key, required this.item}) : super(key: key);

  @override
  State<EditDataDialog> createState() => _EditDataDialogState();
}

class _EditDataDialogState extends State<EditDataDialog> {
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.item.value);
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(storageServiceProvider.notifier);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _valueController,
              decoration: textFieldDecoration(hintText: "Enter Value"),
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_valueController.text);
                    },
                    child: const Text('Update')))
          ],
        ),
      ),
    );
  }
}
class SearchKeyValueDialog extends StatefulWidget {
  const SearchKeyValueDialog({Key? key}) : super(key: key);

  @override
  State<SearchKeyValueDialog> createState() => _SearchKeyValueDialogState();
}

class _SearchKeyValueDialogState extends State<SearchKeyValueDialog> {
  final TextEditingController _keyController = TextEditingController();
  final StorageService _storageService = StorageService();
  String? _value;

  @override
  Widget build(BuildContext context) {
    // ref.watch(storageServiceProvider.notifier);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _keyController,
              decoration: textFieldDecoration(hintText: "Enter Key"),
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      _value = await _storageService
                          .readSecureData(_keyController.text);
                      setState(() {});
                    },
                    child: const Text('Search'))),
            _value == null
                ? const SizedBox()
                : Text(
              'Value: $_value',
            )
          ],
        ),
      ),
    );
  }
}
InputDecoration textFieldDecoration({required String hintText}) {
  return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.only(right: 15, left: 15),
      enabledBorder: InputBorder.none);
}
class VaultCard extends StatefulWidget {
  StorageItem item;

  VaultCard({required this.item, Key? key}) : super(key: key);

  @override
  State<VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends State<VaultCard> {
  bool _visibility = false;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(3, 3),
                    color: Colors.grey.shade300,
                    blurRadius: 5)
              ]),
          child: ListTile(
            onLongPress: () {
              setState(() {
                _visibility = !_visibility;
              });
            },
            title: Text(
              widget.item.key,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: Visibility(
              visible: _visibility,
              child: Text(
                widget.item.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            leading: const Icon(Icons.security, size: 30),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final String updatedValue = await showDialog(
                    context: context,
                    builder: (_) => EditDataDialog(item: widget.item));
                if (updatedValue.isNotEmpty) {
                  _storageService
                      .writeSecureData(
                      StorageItem(widget.item.key, updatedValue))
                      .then((value) {
                    widget.item = StorageItem(widget.item.key, updatedValue);
                    setState(() {});
                  });
                }
              },
            ),
          )),
    );
  }
}