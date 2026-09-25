import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../shared/widgets/app_scaffold.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _controller = PageController();

  int _page = 0;

  final List<_OnboardingItem> _items = const <_OnboardingItem>[
    _OnboardingItem(
      icon: Icons.link,
      title: 'Conecta tu carga',
      description:
          'Encuentra transportistas para tus necesidades ganaderas y agrícolas en Santa Cruz.',
    ),
    _OnboardingItem(
      icon: Icons.compare_arrows,
      title: 'Acuerda el mejor precio',
      description:
          'Recibe ofertas y negocia directamente con quien realizará tu transporte.',
    ),
    _OnboardingItem(
      icon: Icons.directions,
      title: 'Sigue cada trayecto',
      description:
          'Consulta el estado de tu solicitud y acompaña tu viaje activo en tiempo real.',
    ),
  ];

  Future<void> _finish() async {
    await ref.read(onboardingServiceProvider).markCompleted();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_page];
    final isLast = _page == _items.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Omitir'),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (value) {
                  setState(() => _page = value);
                },
                itemBuilder: (context, index) {
                  final current = _items[index];

                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const YavaMark(size: 96),
                        const SizedBox(height: AppSpacing.xl),

                        Icon(current.icon, size: 58, color: AppColors.sunrise),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          current.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          current.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(_items.length, (index) {
                final selected = index == _page;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: selected ? 26 : 8,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navy : const Color(0xFFB7C8BB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(isLast ? 'Comenzar' : 'Siguiente'),
              ),
            ),

            // Mantiene el espacio visual del diseño original.
            Text(
              item.title,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
