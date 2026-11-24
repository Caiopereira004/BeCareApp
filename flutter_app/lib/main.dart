import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'theme/app_strings.dart';
import 'services/api_service.dart';
import 'screens/auth_screen.dart';
import 'screens/tutorials_screen.dart';
import 'widgets/glowup_logo.dart';

void main() {
  runApp(const GlowUpApp());
}

class GlowUpApp extends StatefulWidget {
  const GlowUpApp({super.key});

  @override
  State<GlowUpApp> createState() => _GlowUpAppState();
}

class _GlowUpAppState extends State<GlowUpApp> {
  bool _isPortuguese = true;
  bool _darkMode = false;
  bool _highContrast = false;
  double _textScale = 1.0;
  Map<String, dynamic>? _currentUser;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_textScale)),
      child: MaterialApp(
        title: 'GlowUp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(darkMode: _darkMode, highContrast: _highContrast),
        home: _currentUser == null
            ? AuthScreen(
                isPortuguese: _isPortuguese,
                onToggleLanguage: () => setState(() => _isPortuguese = !_isPortuguese),
                onAuthenticated: (user) => setState(() => _currentUser = user),
              )
            : HomeNavigation(
                user: _currentUser!,
                isPortuguese: _isPortuguese,
                darkMode: _darkMode,
                highContrast: _highContrast,
                textScale: _textScale,
                onToggleDarkMode: (v) => setState(() => _darkMode = v),
                onToggleHighContrast: (v) => setState(() => _highContrast = v),
                onSetTextScale: (v) => setState(() => _textScale = v),
                onLogout: () => setState(() => _currentUser = null),
              ),
      ),
    );
  }
}

class HomeNavigation extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isPortuguese;
  final bool darkMode;
  final bool highContrast;
  final double textScale;
  final ValueChanged<bool> onToggleDarkMode;
  final ValueChanged<bool> onToggleHighContrast;
  final ValueChanged<double> onSetTextScale;
  final VoidCallback onLogout;

  const HomeNavigation({
    super.key,
    required this.user,
    required this.isPortuguese,
    required this.darkMode,
    required this.highContrast,
    required this.textScale,
    required this.onToggleDarkMode,
    required this.onToggleHighContrast,
    required this.onSetTextScale,
    required this.onLogout,
  });

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  // Sempre inicia nulo (nenhuma opção pré-marcada)
  String? _skinType;
  String? _skinGoal;
  String _routinePeriod = 'morning';
  int _waterGlasses = 3;
  double _fridgeTemp = 6.0;
  String _shopCategory = 'all';
  String _shopQuery = '';
  int _avatarPresetIndex = 0;

  final List<IconData> _avatarPresets = [
    Icons.spa_rounded,
    Icons.auto_awesome_rounded,
    Icons.water_drop_rounded,
    Icons.wb_sunny_rounded,
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'Gel de Limpeza Suave', 'cat': 'cleanser', 'brand': 'Drogasil', 'price': 44.90, 'skin': 'Pele Oleosa'},
    {'name': 'Espuma Micelar Fisiológica', 'cat': 'cleanser', 'brand': 'Época Cosméticos', 'price': 49.90, 'skin': 'Pele Mista'},
    {'name': 'Gel Hidratante Ácido Hialurônico', 'cat': 'moisturizer', 'brand': 'Creamy', 'price': 69.90, 'skin': 'Pele Oleosa'},
    {'name': 'Creme Reparador Ceramidas', 'cat': 'moisturizer', 'brand': 'Drogasil', 'price': 64.50, 'skin': 'Pele Seca / Sensível'},
    {'name': 'Protetor Solar Toque Seco FPS 60', 'cat': 'sunscreen', 'brand': 'Drogasil', 'price': 65.00, 'skin': 'Pele Oleosa'},
    {'name': 'Sérum Vitamina C 10% Pura', 'cat': 'serum', 'brand': 'Creamy', 'price': 89.90, 'skin': 'Pele Mista'},
  ];

  final List<Map<String, dynamic>> _cart = [];
  final Set<String> _completedSteps = {};

  List<Map<String, String>> _getTailoredRoutine() {
    if (_routinePeriod == 'morning') {
      if (_skinType == 'Pele Oleosa') {
        return [
          {'step': '1. Gel de Limpeza Oil-Control', 'detail': 'Controla o sebo matinal sem ressecar a barreira.'},
          {'step': '2. Hidratante em Gel Oil-Free', 'detail': 'Textura aquosa leve com Niacinamida.'},
          {'step': '3. Protetor Solar Toque Seco FPS 60', 'detail': 'Efeito matte duradouro.'},
        ];
      } else if (_skinType == 'Pele Seca / Sensível') {
        return [
          {'step': '1. Loção de Limpeza Calmante', 'detail': 'Higienização gentil sem sulfatos.'},
          {'step': '2. Creme Hidratante com Ceramidas', 'detail': 'Nutrição profunda e alívio imediato.'},
          {'step': '3. Protetor Solar Hidratante FPS 50', 'detail': 'Proteção UV com conforto térmico.'},
        ];
      }
      return [
        {'step': '1. Limpeza Facial Suave', 'detail': 'Sabonete facial neutro para iniciar o dia.'},
        {'step': '2. Hidratação Equilibrada', 'detail': 'Hidratante leve com Ácido Hialurônico.'},
        {'step': '3. Proteção Solar Diária FPS 50+', 'detail': 'Aplicar 2 dedos no rosto e pescoço.'},
      ];
    } else {
      if (_skinType == 'Pele Oleosa') {
        return [
          {'step': '1. Limpeza Profunda Suave', 'detail': 'Remove excesso de oleosidade e poluição.'},
          {'step': '2. Sérum Niacinamida 10% (GlowFridge)', 'detail': 'Minimiza poros e uniformiza a textura.'},
          {'step': '3. Gel Noturno Equilibrante', 'detail': 'Hidratação leve durante o sono.'},
        ];
      } else if (_skinType == 'Pele Seca / Sensível') {
        return [
          {'step': '1. Demaquilante & Limpeza Suave', 'detail': 'Preserva o manto hidrolipídico.'},
          {'step': '2. Sérum Pantenol + B5 (GlowFridge)', 'detail': 'Ação calmante refrescante a 6°C.'},
          {'step': '3. Bálsamo Reparador Noturno', 'detail': 'Recuperação intensa da barreira cutânea.'},
        ];
      }
      return [
        {'step': '1. Higienização Noturna', 'detail': 'Remove protetor solar e impurezas acumuladas.'},
        {'step': '2. Sérum Antioxidante (GlowFridge)', 'detail': 'Vitamina C ou Niacinamida refrigerada.'},
        {'step': '3. Hidratação Reparadora Noturna', 'detail': 'Creme facial para regeneração noturna.'},
      ];
    }
  }

  void _openOptionalQuizModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questionário Opcional de Pele', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Escolha seu perfil para personalizar a rotina diurna e noturna (nenhuma opção é obrigatória):',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            _quizOption('Pele Oleosa', 'Controle de Oleosidade', 'Brilho na zona T e poros dilatados', ctx),
            _quizOption('Pele Mista', 'Equilíbrio & Luminosidade', 'Zona T oleosa e bochechas equilibradas', ctx),
            _quizOption('Pele Seca / Sensível', 'Hidratação & Barreira', 'Sensação de repuxamento ou vermelhidão', ctx),
            if (_skinType != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _skinType = null;
                    _skinGoal = null;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Limpar seleção (voltar à rotina padrão)'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quizOption(String type, String goal, String desc, BuildContext ctx) {
    final selected = _skinType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _skinType = type;
          _skinGoal = goal;
        });
        ApiService.saveSkinQuiz(email: widget.user['email'] ?? '', skinType: type, skinGoal: goal);
        Navigator.pop(ctx);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderSubtle, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  Text(desc, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.isPortuguese;
    final pages = [
      _buildHomeTab(),
      _buildFridgeTab(),
      TutorialsScreen(isPortuguese: pt),
      _buildShopTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: GlowUpLogo(size: 36, showWordmark: true, darkMode: widget.darkMode),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary), label: AppStrings.t(pt, 'tab_home')),
          const NavigationDestination(icon: Icon(Icons.ac_unit_outlined), selectedIcon: Icon(Icons.ac_unit_rounded, color: AppColors.primary), label: 'GlowFridge'),
          NavigationDestination(icon: const Icon(Icons.play_circle_outline), selectedIcon: const Icon(Icons.play_circle_rounded, color: AppColors.primary), label: AppStrings.t(pt, 'tab_lessons')),
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary), label: AppStrings.t(pt, 'tab_shop')),
          NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary), label: AppStrings.t(pt, 'tab_profile')),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final userName = widget.user['name'] ?? '';
    final steps = _getTailoredRoutine();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá,',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.champagne,
                        fontSize: 23,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _skinType != null ? '$_skinType • $_skinGoal' : 'Rotina padrão ativa (Questionário opcional)',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13.5),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openOptionalQuizModal,
                      icon: const Icon(Icons.tune_rounded, size: 17),
                      label: Text(_skinType != null ? 'Editar Perfil de Pele' : 'Personalizar Rotina (Opcional)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 4),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(_avatarPresets[_avatarPresetIndex], color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Rotina Diurna')),
                selected: _routinePeriod == 'morning',
                onSelected: (_) => setState(() => _routinePeriod = 'morning'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Rotina Noturna')),
                selected: _routinePeriod == 'night',
                onSelected: (_) => setState(() => _routinePeriod = 'night'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...steps.map((s) {
          final key = '${_routinePeriod}_${s['step']}';
          final done = _completedSteps.contains(key);
          return GestureDetector(
            onTap: () => setState(() => done ? _completedSteps.remove(key) : _completedSteps.add(key)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: done ? AppColors.primary : AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: done ? AppColors.primary : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['step']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                        Text(s['detail']!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.sageSoft, borderRadius: BorderRadius.circular(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hidratação Diária', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.sage)),
                  Text('$_waterGlasses de 8 copos (${_waterGlasses * 250} ml)', style: const TextStyle(color: AppColors.sage)),
                ],
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                onPressed: () => setState(() => _waterGlasses++),
                child: const Text('+ 250 ml'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFridgeTab() {
    final ideal = _fridgeTemp >= 4.0 && _fridgeTemp <= 8.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('GlowFridge IoT', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.fridgeDark, AppColors.fridgeDeep]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text('TEMPERATURA INTERNA', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('${_fridgeTemp.toStringAsFixed(1)} °C', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800)),
              Text(
                ideal ? 'Faixa ideal para antioxidantes (4°C – 8°C)' : 'Fora da faixa ideal recomendada (4°C – 8°C)',
                style: TextStyle(color: ideal ? const Color(0xFF6EE7B7) : const Color(0xFFFCD34D)),
              ),
              Slider(
                value: _fridgeTemp,
                min: 2.0,
                max: 14.0,
                divisions: 24,
                activeColor: AppColors.iceAccent,
                onChanged: (v) {
                  setState(() => _fridgeTemp = v);
                  ApiService.updateFridgeTemperature(v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopTab() {
    final filtered = _products.where((p) {
      final matchCat = _shopCategory == 'all' || p['cat'] == _shopCategory;
      final matchQuery = _shopQuery.isEmpty || (p['name'] as String).toLowerCase().contains(_shopQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Loja & Curadoria', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(hintText: 'Buscar produto...', prefixIcon: Icon(Icons.search_rounded)),
          onChanged: (v) => setState(() => _shopQuery = v),
        ),
        const SizedBox(height: 12),
        ...filtered.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${p['brand']} • ${p['skin']}', style: const TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => setState(() => _cart.add(p)),
                    child: Text('R\$ ${(p['price'] as double).toStringAsFixed(2)}'),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Meu Perfil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primarySoft,
                child: Icon(_avatarPresets[_avatarPresetIndex], size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(widget.user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              Text(widget.user['email'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(_avatarPresets.length, (i) => ChoiceChip(
                  label: Icon(_avatarPresets[i], size: 18),
                  selected: _avatarPresetIndex == i,
                  onSelected: (_) => setState(() => _avatarPresetIndex = i),
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ListTile(
          tileColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: const Icon(Icons.spa_rounded, color: AppColors.primary),
          title: const Text('Questionário de Pele (Opcional)', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(_skinType ?? 'Nenhuma opção marcada • Toque para personalizar'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: _openOptionalQuizModal,
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          title: const Text('Modo Escuro'),
          value: widget.darkMode,
          onChanged: widget.onToggleDarkMode,
        ),
        SwitchListTile(
          title: const Text('Alto Contraste'),
          value: widget.highContrast,
          onChanged: widget.onToggleHighContrast,
        ),
        ListTile(
          title: const Text('Tamanho do Texto'),
          subtitle: Slider(
            value: widget.textScale,
            min: 0.9,
            max: 1.3,
            divisions: 4,
            onChanged: widget.onSetTextScale,
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text('Sair da Conta', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
