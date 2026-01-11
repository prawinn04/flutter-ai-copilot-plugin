# Flutter UI Copilot 🤖

> **"Give your App Eyes and Hands"**  
> Empower your users to interact with your Flutter app using natural language. This plugin connects your UI to Multimodal AI (like OpenAI GPT-4o, Gemini, or Qwen2.5-VL), allowing the AI to "see" the screen and "click" widgets automatically.

![Flutter](https://img.shields.io/badge/Flutter-Tested-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-Proprietary%20%2F%20Non--Commercial-red)
![Pub Version](https://img.shields.io/pub/v/flutter_ui_copilot)

## ✨ Advantages

*   **⚡ Zero-Training**: No need to train custom models. It works with standard Multimodal LLMs.
*   **👁️ Visual Understanding**: The AI sees exactly what the user sees (screenshots).
*   **🖱️ Auto-Pilot**: It can find widgets and **click** them for the user.
*   **🔌 Multi-Provider**: Switch between OpenAI, Google Gemini, Hugging Face, or GitHub Copilot easily.
*   **🛠️ Simple Integration**: Just wrap widgets with `CopilotTag`. No complex accessibility trees or XPaths.

---

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ui_copilot: ^0.0.1
```

Or install it from the command line:

```bash
flutter pub add flutter_ui_copilot
```

---

## 📖 How to Integrate

### 1. Initialize the Provider
Wrap your root widget (usually `MaterialApp`) with `CopilotProvider`.

```dart
import 'package:flutter_ui_copilot/flutter_ui_copilot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CopilotProvider(
      apiKey: "YOUR_API_KEY", // e.g., sk-...
      // Select your AI Brain
      aiProvider: OpenAIProvider(
        model: 'gpt-4o', // or 'Qwen/Qwen2.5-VL-7B-Instruct'
      ),
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
```

### 2. Tag Interactive Widgets
Wrap any button, text field, or widget you want the AI to control with `CopilotTag`.

```dart
CopilotTag(
  id: "add_item_btn", // Unique ID
  description: "Button to add a new item to the list", // Description for AI
  actionCallback: () {
     // This logic runs when AI decides to click this button
     _addItem(); 
  },
  child: FloatingActionButton(
    onPressed: _addItem,
    child: const Icon(Icons.add),
  ),
)
```

### 3. Send Commands
You can trigger the AI from a chat input, a voice command, or a debug button.

```dart
// Inside any widget
final copilot = CopilotProvider.of(context);

// Example User Request
await copilot.sendMessage("Add a new item for me");
// The AI will "see" the screen, find the "add_item_btn", and trigger it.
```

---

## 🛠️ Tasks Performed

The plugin handles the complex "Vision-to-Action" loop for you:

1.  **Capture**: Takes a screenshot of the current UI.
2.  **Contextualize**: Collects descriptions of all `CopilotTag` widgets on screen.
3.  **Reason**: Sends image + widget list to the AI (LLM).
4.  **Action**:
    *   **Highlight**: Draws a visual spotlight on the target widget.
    *   **Execute**: Triggers the `actionCallback` (Click/Tap).
    *   **Navigate**: Can push/pop routes if you wire the callback to `Navigator`.

---

## 🔮 Future Updates

*   **🗣️ Voice Mode**: Talk to your app directly (Speech-to-Text integration).
*   **📜 Scroll Support**: AI will be able to scroll lists to find off-screen items.
*   **📝 Text Input**: AI will be able to type text into fields (e.g., "Fill the form with verify data").
*   **🧠 Local Models**: Support for on-device small vision models for privacy.

---

## ⚠️ Important Notes

*   **API Costs**: Using GPT-4o or Gemini may incur costs from the respective providers.
*   **Permissions**: Ensure your app has Internet permission.
    *   **Android**: `<uses-permission android:name="android.permission.INTERNET"/>`
    *   **macOS**: Enable "Outgoing Connections (Client)".

## 📄 License

**Proprietary / Non-Commercial Use Only**
Copyright (c) 2026 Praveen Kumar. All rights reserved.
See `LICENSE` file for details.
