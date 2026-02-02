import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  // 聊天消息列表（界面展示用）
  final List<Map<String, dynamic>> _messages = [
    {
      'text': '您好！我是您的专属健康客服，工作日9:00-18:00在线~',
      'isUser': false,
      'time': _getCurrentTime(),
    },
  ];

  // 讯飞星火对话历史（API 请求用，格式：[{role, content}]）
  List<Map<String, dynamic>> _xfChatHistory = [];

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false; // 正在加载/回复中
  bool _isInputFocused = false;

  // 讯飞星火配置（替换为你的有效 API Key）
  final String _apiKey = "Bearer xWLVAMGePfIRFvIaeBoA:PnIxuCwYawuOXjpdiVgp";
  final String _xfUrl = "https://spark-api-open.xf-yun.com/v1/chat/completions";
  late Dio _dio; // Dio 实例

  @override
  void initState() {
    super.initState();
    // 初始化 Dio
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 自动滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 获取当前时间（格式：HH:mm）
  static String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // 对话历史长度控制（避免超长，限制 11000 字符）
  List<Map<String, dynamic>> _checkChatHistoryLength(
    List<Map<String, dynamic>> history,
  ) {
    int length = 0;
    for (var item in history) {
      length += item['content'].toString().length;
    }
    while (length > 11000) {
      length -= history[0]['content'].toString().length;
      history.removeAt(0);
    }
    return history;
  }

  // 发送消息（Dio 调用讯飞星火流式 API）
  Future<void> _sendMessage() async {
    final userInput = _textController.text.trim();
    if (userInput.isEmpty || _isTyping) return;

    // 1. 添加用户消息到界面和对话历史
    setState(() {
      _messages.add({
        'text': userInput,
        'isUser': true,
        'time': _getCurrentTime(),
      });
      _xfChatHistory.add({'role': 'user', 'content': userInput});
      _textController.clear();
      _isTyping = true; // 标记为正在回复
    });

    // 2. 自动滚到底部（显示用户消息）
    _scrollToBottom();

    // 3. 处理对话历史长度（避免超长被拒）
    final validChatHistory = _checkChatHistoryLength(_xfChatHistory);

    // 4. 构建讯飞 API 请求参数
    final requestData = {
      "model": "4.0Ultra",
      "user": "user_id",
      "messages": validChatHistory,
      "stream": true,
      "tools": [
        {
          "type": "web_search",
          "web_search": {"enable": true, "search_mode": "deep"},
        },
      ],
    };

    // 5. 构建请求头
    final headers = {
      'Authorization': _apiKey,
      'Content-Type': 'application/json',
    };

    // 6. Dio 发送流式 POST 请求
    try {
      // 存储客服回复内容
      String assistantReply = "";
      // 标记客服消息是否已添加到界面（避免重复添加）
      bool hasAddedAssistantMessage = false;

      // 发送流式请求
      final response = await _dio.post(
        _xfUrl,
        data: jsonEncode(requestData),
        options: Options(
          headers: headers,
          responseType: ResponseType.stream, // 关键：设置响应类型为流式
        ),
      );

      // 处理流式响应（逐行解析）
      final stream = response.data as Stream<List<int>>;
      await for (final chunk in stream) {
        if (chunk.isEmpty) continue;

        // 转换字节流为字符串
        final chunkStr = utf8.decode(chunk);
        // 按行分割（讯飞流式响应每行以 data: 开头）
        final lines = chunkStr
            .split('\n')
            .where((line) => line.isNotEmpty && line.startsWith('data:'))
            .toList();

        for (final line in lines) {
          // 移除前缀 data:
          final dataStr = line.substring(5).trim();
          if (dataStr == '[DONE]') break; // 响应结束标志

          // 解析 JSON 数据
          final dataJson = jsonDecode(dataStr) as Map<String, dynamic>;
          final delta = dataJson['choices'][0]['delta'] as Map<String, dynamic>;

          // 提取回复内容
          if (delta.containsKey('content') && delta['content'] != null) {
            final content = delta['content'] as String;
            if (content.isEmpty) continue;

            // 更新回复内容
            assistantReply += content;

            // 更新界面（实时显示回复，模拟打字效果）
            setState(() {
              // 首次获取到内容时，添加空的客服消息到界面
              if (!hasAddedAssistantMessage) {
                _messages.add({
                  'text': assistantReply,
                  'isUser': false,
                  'time': _getCurrentTime(),
                });
                hasAddedAssistantMessage = true;
              } else {
                // 后续更新已有客服消息的内容
                _messages[_messages.length - 1]['text'] = assistantReply;
              }
            });

            // 自动滚到底部（实时跟随回复）
            _scrollToBottom();
          }
        }
      }

      // 7. 回复完成后，更新对话历史
      if (assistantReply.isNotEmpty) {
        setState(() {
          _xfChatHistory.add({'role': 'assistant', 'content': assistantReply});
        });
      }
    } catch (e) {
      // 异常处理
      setState(() {
        if (!_isTyping) return;
        _messages.add({
          'text': '抱歉，请求出错了：${e.toString()}',
          'isUser': false,
          'time': _getCurrentTime(),
        });
      });
      _scrollToBottom();
    } finally {
      // 8. 结束加载状态
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部返回栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2D3748),
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF4299E1),
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '人工客服',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '工作日 9:00-18:00 在线',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 聊天列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount:
                    _messages.length +
                    (_isTyping && !_messages.last['isUser'] ? 1 : 0),
                itemBuilder: (_, index) {
                  // 正在输入提示（仅当客服未回复完成时显示）
                  if (_isTyping &&
                      !_messages.last['isUser'] &&
                      index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFFE8F4F8),
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF4299E1),
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F4F8),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                    height: 16,
                                    child: ColoredBox(color: Color(0xFF718096)),
                                  ),
                                  SizedBox(width: 4),
                                  SizedBox(
                                    width: 2,
                                    height: 12,
                                    child: ColoredBox(color: Color(0xFF718096)),
                                  ),
                                  SizedBox(width: 4),
                                  SizedBox(
                                    width: 2,
                                    height: 8,
                                    child: ColoredBox(color: Color(0xFF718096)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: msg['isUser']
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        // 客服头像
                        if (!msg['isUser']) ...[
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFFE8F4F8),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF4299E1),
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // 消息气泡
                        Flexible(
                          child: Column(
                            crossAxisAlignment: msg['isUser']
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: msg['isUser']
                                      ? const Color(0xFF4299E1)
                                      : const Color(0xFFE8F4F8),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: msg['isUser']
                                        ? const Radius.circular(16)
                                        : const Radius.circular(4),
                                    bottomRight: msg['isUser']
                                        ? const Radius.circular(4)
                                        : const Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  msg['text'],
                                  style: TextStyle(
                                    color: msg['isUser']
                                        ? Colors.white
                                        : const Color(0xFF2D3748),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              // 时间戳
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 10,
                                  right: 10,
                                ),
                                child: Text(
                                  msg['time'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 用户头像
                        if (msg['isUser']) ...[
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFFEEEEEE),
                            child: Icon(
                              Icons.person_outline,
                              color: Color(0xFF2D3748),
                              size: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            // 输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (value) => _sendMessage(),
                      onTap: () => setState(() => _isInputFocused = true),
                      onEditingComplete: () =>
                          setState(() => _isInputFocused = false),
                      decoration: InputDecoration(
                        hintText: '输入您的问题...',
                        hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: _isInputFocused
                                ? const Color(0xFF4299E1)
                                : const Color(0xFFEEEEEE),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFEEEEEE),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF4299E1),
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                      ),
                      enabled: !_isTyping, // 加载中禁用输入框
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          (_textController.text.trim().isNotEmpty && !_isTyping)
                          ? const Color(0xFF4299E1)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _isTyping ? null : _sendMessage, // 加载中禁用发送按钮
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
