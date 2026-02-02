import 'package:aaa/api/user.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      var res = await login(_phoneController.text, _passwordController.text);
      if (!mounted) return;

      if (res["code"] != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('手机号或密码错误')));
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigationPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入手机号和密码')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text(
                  '健康监测App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4299E1),
                  ),
                ),
                const SizedBox(height: 60),
                ShadInputFormField(
                  id: 'phone',
                  controller: _phoneController,
                  label: Text('手机号', style: ShadTheme.of(context).textTheme.p),
                  placeholder: const Text('请输入手机号'),
                  validator: (v) {
                    if (v.isEmpty) {
                      return '手机号不能为空';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'password',
                  placeholder: const Text("请输入密码"),
                  controller: _passwordController,
                  label: Text('密码', style: ShadTheme.of(context).textTheme.p),
                  obscureText: !_isPasswordVisible,
                  leading: Icon(LucideIcons.lock),
                  trailing: ShadButton(
                    width: 24,
                    height: 24,
                    padding: EdgeInsetsGeometry.zero,
                    onPressed: () => setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    }),
                    child: Icon(
                      _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    ),
                  ),
                  validator: (v) {
                    if (v.isEmpty) {
                      return '密码不能为空';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ShadButton(onPressed: _handleLogin, child: const Text('登录')),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('还没有账号？'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('去注册'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _handleRegister() async {
    if (_phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('两次密码不一致')));
      return;
    }

    var res = await register(_phoneController.text, _passwordController.text);
    if (!mounted) return;

    if (res["code"] != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["msg"])));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('注册成功')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ShadInputFormField(
              id: 'phone',
              controller: _phoneController,
              label: Text('手机号', style: ShadTheme.of(context).textTheme.p),
              placeholder: const Text('请输入手机号'),
            ),
            const SizedBox(height: 16),
            ShadInputFormField(
              id: 'password',
              controller: _passwordController,
              label: Text('密码', style: ShadTheme.of(context).textTheme.p),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ShadInputFormField(
              id: 'confirm',
              controller: _confirmController,
              label: Text('确认密码', style: ShadTheme.of(context).textTheme.p),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ShadButton(onPressed: _handleRegister, child: const Text('注册')),
          ],
        ),
      ),
    );
  }
}
