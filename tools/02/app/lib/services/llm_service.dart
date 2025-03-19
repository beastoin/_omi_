import 'dart:convert';
import 'package:http/http.dart' as http;
import '../tools/tool_manager.dart';

class LlmService {
  final String _apiKey;
  final String _apiEndpoint;
  final String _model;

  LlmService({
    required String apiKey,
    String apiEndpoint = 'https://api.openai.com/v1/chat/completions',
    String model = 'gpt-3.5-turbo',
  })  : _apiKey = apiKey,
        _apiEndpoint = apiEndpoint,
        _model = model;

  /// Corrects grammar in the provided text
  Future<String> correctGrammar(String text) async {
    try {
      final prompt = '''
Please correct the grammar, spelling, and punctuation in the following text. 
Maintain the original meaning and style, but fix any errors:

"$text"

Return only the corrected text, with no additional explanations, comments, or ellipses (...).
Do not add any quotation marks or formatting to the output.
''';

      // Make API request to LLM
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that corrects grammar, spelling, and punctuation.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final correctedText = data['choices'][0]['message']['content'].toString().trim();
        return correctedText;
      } else {
        throw Exception('Failed to get response from LLM: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error correcting grammar: $e');
    }
  }

  /// Selects the most appropriate tool based on the command
  Future<String> selectTool(String command, List<Tool> tools) async {
    try {
      // Create a prompt that describes the task and lists available tools
      final toolDescriptions = tools.map((tool) => 
        "- ${tool.name}: ${tool.description}"
      ).join('\n');
      
      final prompt = '''
I need to select the most appropriate tool to handle this user command: "$command"

Available tools:
$toolDescriptions

Return ONLY the name of the single most appropriate tool. Just the tool name, nothing else.
''';

      // Make API request to LLM
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that selects the most appropriate tool based on a user command.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final toolName = data['choices'][0]['message']['content'].toString().trim();
        return toolName;
      } else {
        throw Exception('Failed to get response from LLM: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error selecting tool: $e');
    }
  }
}
