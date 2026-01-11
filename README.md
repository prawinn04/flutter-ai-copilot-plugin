# Flutter UI Copilot 🤖

> **A Flutter plugin that gives your app "Vision" and "Control".**  
> Empower your users to interact with your app using natural language (e.g., "Click the add button", "Go to settings").

![Flutter](https://img.shields.io/badge/Flutter-Tested-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-Proprietary%20%2F%20Non--Commercial-red)

## ✨ Features

*   **👁️ Visual Understanding**: Automatically captures screenshots and sends them to Multimodal AI (OpenAI, Gemini, Hugging Face).
*   **🖱️ Auto-Pilot**: The AI can **highlight** widgets and automatically **click/tap** them to perform actions.
*   **🔌 Multi-Provider**: Support for:
    *   **Google Gemini** (Flash 1.5)
    *   **Hugging Face** (Qwen2.5-VL for vision, Gemma/DeepSeek for text)
    *   **OpenAI** (GPT-4o)
    *   **GitHub Copilot** (Enterprise)

## 🚀 Installation

Add the plugin to your `pubspec.yaml` (local path for now):

```yaml
dependencies:
  flutter_ui_copilot:
    path: ./path/to/flutter_ui_copilot
```

## 🛠️ Usage

### 1. Initialize Provider
Wrap your root `MaterialApp` with `CopilotProvider`.

```dart
CopilotProvider(
  apiKey: "YOUR_API_KEY",
  // Choose your provider
  aiProvider: GeminiProvider(model: 'gemini-1.5-flash'),
  // OR
  // aiProvider: OpenAIProvider(
  //   model: 'Qwen/Qwen2.5-VL-7B-Instruct',
  //   baseUrl: 'https://router.huggingface.co/v1/chat/completions',
  //   supportsImages: true,
  // ),
  child: MyApp(),
)
```

### 2. Tag Your Widgets
Wrap interactive elements with `CopilotTag`. This tells the AI what the widget is and gives it a way to click it.

```dart
CopilotTag(
  id: "increment_btn",
  description: "Button to increase the count",
  actionCallback: _incrementCounter, // logic to run when AI clicks this
  child: FloatingActionButton(
    onPressed: _incrementCounter,
    child: Icon(Icons.add),
  ),
)
```

### 3. Send Commands
Trigger the AI from anywhere (e.g., a chat input).

```dart
final copilot = CopilotProvider.of(context);
await copilot.sendMessage("Click the add button");
```

## 🧠 Supported Actions

| Action | Description |
| :--- | :--- |
| **Highlight** | Draws a spotlight overlay on the target widget. |
| **Click/Tap** | Highlights the widget and then executes the `actionCallback`. |
| **Navigate** | Use `actionCallback` to `Navigator.push` or `pop` to handle screen changes naturally. |

## ⚠️ Requirements

*   **Internet Access**: Required for API calls.
    *   *Android*: Ensure `<uses-permission android:name="android.permission.INTERNET"/>` is in `AndroidManifest.xml`.
    *   *macOS*: Enable "Outgoing Connections (Client)" in Entitlements.

---

## 📄 License & Restrictions

**Copyright (c) 2026 Praveen Kumar. All rights reserved.**

This software is for **Educational and Non-Commercial Use Only**. 
The core concepts and ideas implemented herein are the intellectual property of the author. Commercial reproduction or usage is strictly prohibited.
