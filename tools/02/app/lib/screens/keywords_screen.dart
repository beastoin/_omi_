import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transcript_manager.dart';
import '../theme/nintendo_theme.dart';

class KeywordsScreen extends StatefulWidget {
  const KeywordsScreen({Key? key}) : super(key: key);

  @override
  State<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends State<KeywordsScreen> {
  final TextEditingController _keywordController = TextEditingController();
  late List<String> _keywords;

  @override
  void initState() {
    super.initState();
    final manager = Provider.of<TranscriptManager>(context, listen: false);
    _keywords = List.from(manager.keywords);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final keyword = _keywordController.text.trim().toLowerCase();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(int index) {
    setState(() {
      _keywords.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.keyboard_voice, size: 24),
            SizedBox(width: 8),
            Text('Keyword Triggers'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? NintendoTheme.nintendoDarkGray
                  : NintendoTheme.nintendoLightGray.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add keyword section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: NintendoTheme.neonBlue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: NintendoTheme.neonBlue,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: NintendoTheme.neonBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Keyword',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NintendoTheme.neonBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _keywordController,
                            decoration: InputDecoration(
                              labelText: 'Keyword or phrase',
                              hintText: 'e.g., hey flow',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.keyboard,
                                color: NintendoTheme.neonBlue,
                              ),
                            ),
                            onSubmitted: (_) => _addKeyword(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addKeyword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NintendoTheme.neonBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Keywords list section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NintendoTheme.nintendoDarkGray.withOpacity(0.7)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: NintendoTheme.neonRed.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: NintendoTheme.neonRed,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list,
                            color: NintendoTheme.neonRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keyword Triggers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NintendoTheme.neonRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'These keywords will trigger the "I am here" notification',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _keywords.isEmpty
                            ? Center(
                                child: Text(
                                  'No keywords added yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _keywords.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: NintendoTheme.neonRed.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _keywords[index],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: NintendoTheme.neonRed,
                                        ),
                                        onPressed: () => _removeKeyword(index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Save button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: NintendoTheme.neonYellow.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final manager = Provider.of<TranscriptManager>(context, listen: false);
                    await manager.saveSettings(keywords: _keywords);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Keywords saved!'),
                          backgroundColor: NintendoTheme.neonYellow,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NintendoTheme.neonYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        NintendoTheme.neonRed,
                        NintendoTheme.neonBlue,
                      ],
                    ).createShader(bounds),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'SAVE KEYWORDS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.2,
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
      ),
    );
  }
}
