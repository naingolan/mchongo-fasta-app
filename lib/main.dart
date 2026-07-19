import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

void main() {
  runApp(const MchongoFastaApp());
}

class MchongoFastaApp extends StatefulWidget {
  const MchongoFastaApp({super.key, this.skipIntro = false});

  /// Used by widget tests to jump straight into the marketplace shell.
  final bool skipIntro;

  @override
  State<MchongoFastaApp> createState() => _MchongoFastaAppState();
}

class _MchongoFastaAppState extends State<MchongoFastaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MchongoFasta',
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: widget.skipIntro
          ? HomeShell(onThemeToggle: _toggleTheme)
          : SplashScreen(
              onFinished: () {},
              childBuilder: (context) => OnboardingScreen(
                onDone: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => HomeShell(onThemeToggle: _toggleTheme),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.childBuilder,
    required this.onFinished,
  });

  final WidgetBuilder childBuilder;
  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.childBuilder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      widget.onFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MfColors.primary,
      body: Center(
        child: Text(
          'MchongoFasta.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardPage(
      title: 'Find verified daily work with MchongoFasta.',
      body:
          'Cleaning, delivery, care and repairs around Dar — matched fast with ratings and safe pay.',
      cardTitle: 'Today earnings',
      cardValue: 'TZS 128,500',
      chipLabel: 'Jobs nearby 12',
    ),
    _OnboardPage(
      title: 'Trust first. National ID and skill checks.',
      body:
          'Workers complete verification before matching. Employers hire with confidence.',
      cardTitle: 'Verified workers',
      cardValue: '8,400+',
      chipLabel: 'Trust score 96%',
    ),
    _OnboardPage(
      title: 'Post a task. Get help in minutes.',
      body:
          'Households and SMEs post short-term work, review applicants, then pay securely in-app.',
      cardTitle: 'Matched today',
      cardValue: '42 jobs',
      chipLabel: 'Avg match 4 min',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MfColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _OnboardingHero(page: item)),
                        const SizedBox(height: 28),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.6,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.body,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: MfColors.muted,
                                height: 1.5,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 6),
                    height: 8,
                    width: active ? 28 : 8,
                    decoration: BoxDecoration(
                      color: active ? MfColors.primary : MfColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _next,
                child: Text(
                  _index == _pages.length - 1 ? 'Get Started' : 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.title,
    required this.body,
    required this.cardTitle,
    required this.cardValue,
    required this.chipLabel,
  });

  final String title;
  final String body;
  final String cardTitle;
  final String cardValue;
  final String chipLabel;
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.page});

  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MfColors.primary,
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MfColors.primary, MfColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.north_east_rounded,
                      color: MfColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  page.cardTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  page.cardValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    page.chipLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum UserRole { worker, employer }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0;
  UserRole _role = UserRole.worker;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      DiscoverPage(role: _role),
      const PostJobPage(),
      const VerificationPage(),
      const WalletPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const BrandMark(),
        actions: [
          IconButton(
            tooltip: isDark ? 'Use light mode' : 'Use dark mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfilePage(onThemeToggle: widget.onThemeToggle),
                ),
              );
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.worker,
                      label: Text('Worker'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                    ButtonSegment(
                      value: UserRole.employer,
                      label: Text('Employer'),
                      icon: Icon(Icons.business_center_outlined),
                    ),
                  ],
                  selected: {_role},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return MfColors.primary;
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return MfColors.muted;
                    }),
                    side: const WidgetStatePropertyAll(BorderSide.none),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  onSelectionChanged: (value) =>
                      setState(() => _role = value.first),
                ),
              ),
            ),
            Expanded(child: pages[_page]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (index) => setState(() => _page = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            label: 'Find',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            label: 'Verify',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: MfColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MchongoFasta',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Daily work, verified fast',
              style: text.labelSmall?.copyWith(color: MfColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key, required this.role});

  final UserRole role;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _category = 'All';

  final List<Job> _jobs = const [
    Job(
      title: 'House cleaning in Mikocheni',
      category: 'Domestic',
      pay: 'TZS 35,000',
      distance: '1.8 km',
      time: 'Today 10:30',
      rating: '4.9',
      verified: true,
    ),
    Job(
      title: 'Errand run to Kariakoo',
      category: 'Logistics',
      pay: 'TZS 18,000',
      distance: '3.4 km',
      time: 'Today 13:00',
      rating: '4.7',
      verified: true,
    ),
    Job(
      title: 'Paint two office rooms',
      category: 'Technical',
      pay: 'TZS 95,000',
      distance: '5.2 km',
      time: 'Tomorrow',
      rating: '4.8',
      verified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.role == UserRole.worker;
    final visibleJobs = _category == 'All'
        ? _jobs
        : _jobs.where((job) => job.category == _category).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        HeroPanel(isWorker: isWorker),
        const SizedBox(height: 18),
        SectionHeader(
          title: isWorker ? 'Nearby mchongo' : 'Hiring desk',
          action: isWorker ? 'Map' : 'Drafts',
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Domestic', 'Logistics', 'Care', 'Technical']
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                      labelStyle: TextStyle(
                        color: _category == category
                            ? Colors.white
                            : MfColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (isWorker)
          ...visibleJobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(job: job),
            ),
          )
        else
          const EmployerDashboard(),
      ],
    );
  }
}

class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key, required this.isWorker});

  final bool isWorker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MfColors.primary, MfColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: MfColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                icon: Icons.shield_outlined,
                label: isWorker ? 'Verification: 78%' : 'Employer trusted',
                onDark: true,
              ),
              const Spacer(),
              const Icon(Icons.near_me_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isWorker
                ? 'Find verified daily work around Dar.'
                : 'Hire reliable help in minutes.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isWorker
                ? 'Cleaning, delivery, care, repairs and errands with ratings, safe payments and fast matching.'
                : 'Post a task, review vetted workers, track completion, then rate and pay securely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: MfColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    isWorker ? Icons.work_outline : Icons.add_task_outlined,
                  ),
                  label: Text(isWorker ? 'Accept mchongo' : 'Post task'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Open scanner',
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MfColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                job.verified
                    ? Icons.verified_outlined
                    : Icons.pending_actions_outlined,
                color: job.verified ? MfColors.primary : MfColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(icon: Icons.category_outlined, label: job.category),
              StatusPill(icon: Icons.place_outlined, label: job.distance),
              StatusPill(icon: Icons.star_border_outlined, label: job.rating),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                job.pay,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MfColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                job.time,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: MfColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MetricGrid(),
        SizedBox(height: 12),
        WorkerMatchCard(
          name: 'Asha Mwinyi',
          service: 'Cleaning specialist',
          rating: '4.9',
          distance: '1.1 km',
          completed: '128 jobs',
        ),
        SizedBox(height: 10),
        WorkerMatchCard(
          name: 'Juma Said',
          service: 'Delivery and errands',
          rating: '4.8',
          distance: '2.6 km',
          completed: '86 jobs',
        ),
      ],
    );
  }
}

class WorkerMatchCard extends StatelessWidget {
  const WorkerMatchCard({
    super.key,
    required this.name,
    required this.service,
    required this.rating,
    required this.distance,
    required this.completed,
  });

  final String name;
  final String service;
  final String rating;
  final String distance;
  final String completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MfColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: MfColors.primary,
          child: Text(
            name.characters.first,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('$service • $distance • $completed'),
        trailing: StatusPill(icon: Icons.star_border, label: rating),
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.75,
      children: const [
        MetricTile(value: '42', label: 'matched today'),
        MetricTile(value: '96%', label: 'completion rate'),
        MetricTile(value: 'TZS 1.8M', label: 'paid out'),
        MetricTile(value: '18', label: 'pending vetting'),
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: MfColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: MfColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: MfColors.muted),
          ),
        ],
      ),
    );
  }
}

class PostJobPage extends StatelessWidget {
  const PostJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const SectionHeader(title: 'Post a task', action: 'Templates'),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Task title',
            hintText: 'Example: Clean a 3 bedroom house',
            prefixIcon: Icon(Icons.title_outlined),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Details',
            hintText: 'Location, timing, tools needed and expected output',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Budget',
                  hintText: 'TZS',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'When',
                  hintText: 'Today',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bolt_outlined),
          label: const Text('Match verified workers'),
        ),
      ],
    );
  }
}

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: const [
        SectionHeader(title: 'Verification', action: 'Help'),
        SizedBox(height: 12),
        VerificationStep(
          icon: Icons.perm_identity_outlined,
          title: 'National ID',
          subtitle: 'NIDA or passport document captured',
          done: true,
        ),
        VerificationStep(
          icon: Icons.home_work_outlined,
          title: 'Address check',
          subtitle: 'Dar es Salaam residence confirmation',
          done: true,
        ),
        VerificationStep(
          icon: Icons.handshake_outlined,
          title: 'Reference call',
          subtitle: 'One referee pending support review',
          done: false,
        ),
        SizedBox(height: 14),
        FilledButton(onPressed: null, child: Text('Verification in review')),
      ],
    );
  }
}

class VerificationStep extends StatelessWidget {
  const VerificationStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: ListTile(
          leading: Icon(icon, color: done ? MfColors.primary : MfColors.muted),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? MfColors.primary : MfColors.muted,
          ),
        ),
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const SectionHeader(title: 'Wallet', action: 'Statement'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MfColors.primary, MfColors.primaryDark],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TZS 128,500',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _WalletAction(
                      icon: Icons.call_received,
                      label: 'Withdraw',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _WalletAction(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Premium',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const TransactionRow(
          title: 'Cleaning job completed',
          amount: '+ TZS 35,000',
        ),
        const TransactionRow(
          title: 'MchongoFasta commission',
          amount: '- TZS 3,500',
        ),
        const TransactionRow(title: 'Priority listing', amount: '- TZS 8,000'),
      ],
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.title, required this.amount});

  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          title: Text(title),
          trailing: Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: amount.startsWith('+')
                  ? MfColors.primary
                  : MfColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SizedBox(height: 8),
          const CircleAvatar(
            radius: 48,
            backgroundColor: MfColors.primary,
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Asha Mwinyi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verified cleaning specialist',
            textAlign: TextAlign.center,
            style: TextStyle(color: MfColors.muted),
          ),
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.account_balance_outlined,
            label: 'Payout accounts',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.payments_outlined,
            label: 'Payment requests',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Theme',
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: MfColors.primary,
              onChanged: (_) => onThemeToggle(),
            ),
          ),
          _ProfileTile(
            icon: Icons.security_outlined,
            label: 'Security',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.description_outlined,
            label: 'Statements & reports',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: MfColors.primary,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: MfColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            controller: TextEditingController(text: 'asha@mchongofasta.co.tz'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            controller: TextEditingController(text: 'Asha Mwinyi'),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
            controller: TextEditingController(text: 'password'),
          ),
          const SizedBox(height: 20),
          const FilledButton(onPressed: null, child: Text('Save changes')),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: MfColors.ink),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: const TextStyle(
              color: MfColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    this.onDark = false,
  });

  final IconData icon;
  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: onDark ? Colors.white : MfColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: onDark ? Colors.white : MfColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class Job {
  const Job({
    required this.title,
    required this.category,
    required this.pay,
    required this.distance,
    required this.time,
    required this.rating,
    required this.verified,
  });

  final String title;
  final String category;
  final String pay;
  final String distance;
  final String time;
  final String rating;
  final bool verified;
}
