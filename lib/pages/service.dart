import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _chatHistory = [];

  bool _isLoading = false;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer xWLVAMGePfIRFvIaeBoA:PnIxuCwYawuOXjpdiVgp',
        'Content-Type': 'application/json',
      },
    ),
  );

  final String _url = 'https://spark-api-open.xf-yun.com/v1/chat/completions';

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(text: '您好 👋 我是您的健康管理智能客服，有什么可以帮您的吗？', isUser: false),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });

    _chatHistory.add({'role': 'user', 'content': text});

    _scrollToBottom();

    try {
      final response = await _dio.post(
        _url,
        data: {
          "model": "4.0Ultra",
          "user": "user_id",
          "messages": _chatHistory,
          "stream": false, // ⚠️ 先不用 stream，稳定第一
        },
      );

      final content = response.data['choices'][0]['message']['content'];

      _chatHistory.add({'role': 'assistant', 'content': content});

      setState(() {
        _messages.add(_ChatMessage(text: content, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: '请求失败：$e', isUser: false));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('智能客服')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _messages[i],
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(8), child: Text('客服正在回复中…')),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(hintText: '请输入问题'),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
