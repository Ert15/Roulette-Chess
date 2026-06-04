import 'dart:ui';
import 'package:flutter/material.dart';

class GameMenuOverlay extends StatefulWidget {
  final VoidCallback onStart;
  final bool soundEnabled;
  final double volume;
  final String language;

  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<String> onLanguageChanged;

  const GameMenuOverlay({
    super.key,
    required this.onStart,
    required this.soundEnabled,
    required this.volume,
    required this.language,
    required this.onSoundChanged,
    required this.onVolumeChanged,
    required this.onLanguageChanged,
  });

  @override
  State<GameMenuOverlay> createState() => _GameMenuOverlayState();
}

class _GameMenuOverlayState extends State<GameMenuOverlay> {
  bool showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: const Color(0xFF101326).withOpacity(0.88),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: showSettings ? _settingsCard() : _mainMenuCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainMenuCard() {
    return Container(
      key: const ValueKey('main_menu'),
      width: 330,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D33),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFFB13B),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '♟ Roulette Chess 🔫',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Шахматная рулетка',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 34),
          _menuButton(
            title: 'Старт',
            icon: Icons.play_arrow_rounded,
            onTap: widget.onStart,
            filled: true,
          ),
          const SizedBox(height: 14),
          _menuButton(
            title: 'Настройки',
            icon: Icons.settings_rounded,
            onTap: () {
              setState(() {
                showSettings = true;
              });
            },
            filled: false,
          ),
        ],
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      key: const ValueKey('settings_menu'),
      width: 340,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D33),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFFB13B),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showSettings = false;
                  });
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Настройки',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          _soundBlock(),
          const SizedBox(height: 26),
          _languageBlock(),
        ],
      ),
    );
  }

  Widget _soundBlock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF25283D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: const Color(0xFFFFB13B),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Звук',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: widget.soundEnabled,
                activeColor: const Color(0xFFFFB13B),
                onChanged: widget.onSoundChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: widget.volume,
            min: 0,
            max: 1,
            activeColor: const Color(0xFFFFB13B),
            inactiveColor: Colors.white24,
            onChanged: widget.soundEnabled ? widget.onVolumeChanged : null,
          ),
        ],
      ),
    );
  }

  Widget _languageBlock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF25283D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Язык',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _languageButton(
                  flag: '🇷🇺',
                  title: 'Русский',
                  value: 'ru',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _languageButton(
                  flag: '🇬🇧',
                  title: 'English',
                  value: 'en',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageButton({
    required String flag,
    required String title,
    required String value,
  }) {
    final bool selected = widget.language == value;

    return GestureDetector(
      onTap: () => widget.onLanguageChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFB13B) : const Color(0xFF191C2F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFB13B)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Column(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: selected ? const Color(0xFF1B1730) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              filled ? const Color(0xFFFFB13B) : const Color(0xFF25283D),
          foregroundColor: filled ? const Color(0xFF1B1730) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: filled
                ? BorderSide.none
                : BorderSide(
                    color: Colors.white.withOpacity(0.12),
                  ),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
