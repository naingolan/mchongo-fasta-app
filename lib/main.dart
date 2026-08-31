import 'package:flutter/material.dart';
import 'package:mobile/models/job.dart';
import 'package:mobile/models/user_role.dart';
import 'package:mobile/screens/auth_flow.dart';
import 'package:mobile/screens/job_details_screen.dart';
import 'package:mobile/screens/post_task_flow.dart';
import 'package:mobile/screens/worker_profile.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/brand_logo.dart';
import 'package:mobile/widgets/jobs_map_view.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/role_sheets.dart';
import 'package:mobile/widgets/tab_icons.dart';

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
          ? HomeShell(
              onThemeToggle: _toggleTheme,
              skipEmployerSheet: true,
            )
          : SplashScreen(
              onFinished: () {},
              childBuilder: (context) => OnboardingScreen(
                onDone: () {
                  // New users land on jobs (worker browse) by default.
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MfBrandIcon(
              size: 96,
              color: Colors.white,
              accentColor: Colors.white70,
            ),
            SizedBox(height: 24),
            Text(
              'Mchongo Fasta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      title: 'Find verified daily work with Mchongo Fasta.',
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
                                fontWeight: FontWeight.w700,
                                height: 1.25,
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

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.onThemeToggle,
    this.skipEmployerSheet = false,
    this.loggedIn = false,
    this.role = UserRole.worker,
  });

  final VoidCallback onThemeToggle;
  final bool skipEmployerSheet;
  final bool loggedIn;
  final UserRole role;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0;

  bool get _loggedIn => widget.loggedIn;
  UserRole get _role => widget.role;

  @override
  void initState() {
    super.initState();
    if (!widget.skipEmployerSheet && !_loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showEmployerInviteSheet(
          context: context,
          onEmployerSignIn: () => _startAuth(UserRole.employer),
        );
      });
    }
  }

  void _startAuth(UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthFlowScreen(
          role: role,
          homeBuilder: (_) => HomeShell(
            onThemeToggle: widget.onThemeToggle,
            skipEmployerSheet: true,
            loggedIn: true,
            role: role,
          ),
        ),
      ),
    );
  }

  Future<void> _openPostTaskFlow(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostTaskFlowScreen()),
    );
  }

  Future<void> _onJobTap(Job job) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(
          job: job,
          loggedIn: _loggedIn,
          role: _role,
          onSignIn: () => _startAuth(UserRole.worker),
        ),
      ),
    );
  }

  Future<void> _onProtectedTab(int index) async {
    final isEmployer = _loggedIn && _role == UserRole.employer;

    // Find / Hire is always open.
    if (index == 0) {
      setState(() => _page = index);
      return;
    }

    if (!_loggedIn) {
      // Guest: Post opens employer invite; others need worker login.
      if (index == 1) {
        await showEmployerInviteSheet(
          context: context,
          onEmployerSignIn: () => _startAuth(UserRole.employer),
        );
        return;
      }
      await showLoginToGetJobSheet(
        context: context,
        title: 'Sign in to continue',
        message:
            'Create or sign in to access profile, wallet, and account tools.',
        onSignIn: () => _startAuth(UserRole.worker),
      );
      return;
    }

    if (isEmployer) {
      // Hire, Post, Wallet, Profile
      setState(() => _page = index);
      return;
    }

    // Worker: Find, Verify, Wallet, Profile
    setState(() => _page = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEmployer = _loggedIn && _role == UserRole.employer;
    final isWorker = _loggedIn && _role == UserRole.worker;
    final workerStats = demoWorkerStats();

    final pages = <Widget>[
      DiscoverPage(
        role: isEmployer ? UserRole.employer : UserRole.worker,
        loggedIn: _loggedIn,
        onJobTap: _onJobTap,
        onEmployerCta: () => showEmployerInviteSheet(
          context: context,
          onEmployerSignIn: () => _startAuth(UserRole.employer),
        ),
        onPostTask: () => _openPostTaskFlow(context),
      ),
      if (isWorker) ...[
        const VerificationPage(),
        const WalletPage(),
        WorkerProfileTab(
          onThemeToggle: widget.onThemeToggle,
          stats: workerStats,
        ),
      ] else if (isEmployer) ...[
        PostJobPage(onStartPost: () => _openPostTaskFlow(context)),
        const WalletPage(),
        EmployerProfileTab(onThemeToggle: widget.onThemeToggle),
      ] else ...[
        PostJobPage(
          onStartPost: () => showEmployerInviteSheet(
            context: context,
            onEmployerSignIn: () => _startAuth(UserRole.employer),
          ),
        ),
        const VerificationPage(),
        const WalletPage(),
      ],
    ];

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.travel_explore_outlined),
        label: isEmployer ? 'Hire' : 'Find',
      ),
      if (isWorker) ...[
        const NavigationDestination(
          icon: Icon(Icons.verified_user_outlined),
          label: 'Verify',
        ),
        const NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Wallet',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ] else if (isEmployer) ...[
        const NavigationDestination(
          icon: Icon(Icons.add_box_outlined),
          label: 'Post',
        ),
        const NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Wallet',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ] else ...[
        const NavigationDestination(
          icon: Icon(Icons.add_box_outlined),
          label: 'Post',
        ),
        const NavigationDestination(
          icon: Icon(Icons.verified_user_outlined),
          label: 'Verify',
        ),
        const NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Wallet',
        ),
      ],
    ];

    final safeIndex = _page.clamp(0, pages.length - 1);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 20,
        title: const BrandMark(),
        actions: [
          if (!_loggedIn)
            TextButton(
              onPressed: () => showEmployerInviteSheet(
                context: context,
                onEmployerSignIn: () => _startAuth(UserRole.employer),
              ),
              child: const Text(
                'Employer?',
                style: TextStyle(
                  color: MfColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  isEmployer ? 'Employer' : 'Worker',
                  style: const TextStyle(
                    color: MfColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: isDark ? 'Use light mode' : 'Use dark mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: pages[safeIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onProtectedTab,
        destinations: destinations,
      ),
    );
  }
}

class EmployerProfileTab extends StatelessWidget {
  const EmployerProfileTab({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: MfColors.primary,
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employer account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Text(
                    'Hire verified workers nearby',
                    style: TextStyle(color: MfColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileSettingsPage(onThemeToggle: onThemeToggle),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: MfColors.line),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hiring snapshot',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('Jobs posted: 12', style: TextStyle(color: MfColors.muted)),
              SizedBox(height: 6),
              Text('Workers hired: 9', style: TextStyle(color: MfColors.muted)),
              SizedBox(height: 6),
              Text(
                'Avg match time: 4 min',
                style: TextStyle(color: MfColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MfBrandIcon(
          size: 30,
          color: isDark ? MfColors.primarySoft : MfColors.primary,
          accentColor: isDark ? MfColors.primary : MfColors.primaryDark,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mchongo Fasta',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Daily work, verified fast',
              style: text.labelSmall?.copyWith(
                color: isDark ? MfColors.mutedDark : MfColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    super.key,
    required this.role,
    required this.loggedIn,
    required this.onJobTap,
    required this.onEmployerCta,
    this.onPostTask,
  });

  final UserRole role;
  final bool loggedIn;
  final ValueChanged<Job> onJobTap;
  final VoidCallback onEmployerCta;
  final VoidCallback? onPostTask;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

enum _DiscoverView { map, list }

class _DiscoverPageState extends State<DiscoverPage> {
  String _category = 'All';
  _DiscoverView _view = _DiscoverView.map;

  final List<Job> _jobs = const [
    Job(
      title: 'House cleaning in Mikocheni',
      category: 'Domestic',
      pay: 'TZS 35,000',
      distance: '1.8 km',
      time: 'Today 10:30',
      rating: '4.9',
      verified: true,
      latitude: -6.7550,
      longitude: 39.2500,
    ),
    Job(
      title: 'Errand run to Kariakoo',
      category: 'Logistics',
      pay: 'TZS 18,000',
      distance: '3.4 km',
      time: 'Today 13:00',
      rating: '4.7',
      verified: true,
      latitude: -6.8235,
      longitude: 39.2750,
    ),
    Job(
      title: 'Paint two office rooms in Masaki',
      category: 'Technical',
      pay: 'TZS 95,000',
      distance: '5.2 km',
      time: 'Tomorrow',
      rating: '4.8',
      verified: true,
      latitude: -6.7450,
      longitude: 39.2800,
    ),
    Job(
      title: 'Elderly care assistance in Kinondoni',
      category: 'Care',
      pay: 'TZS 50,000',
      distance: '2.4 km',
      time: 'Today 15:00',
      rating: '4.9',
      verified: true,
      latitude: -6.7800,
      longitude: 39.2600,
    ),
    Job(
      title: 'Laundry & deep kitchen cleaning in Sinza',
      category: 'Domestic',
      pay: 'TZS 40,000',
      distance: '3.1 km',
      time: 'Today 11:30',
      rating: '4.8',
      verified: true,
      latitude: -6.7850,
      longitude: 39.2250,
    ),
    Job(
      title: 'AC repair and servicing in Posta',
      category: 'Technical',
      pay: 'TZS 75,000',
      distance: '4.0 km',
      time: 'Today 14:00',
      rating: '4.9',
      verified: true,
      latitude: -6.8160,
      longitude: 39.2900,
    ),
    Job(
      title: 'Furniture moving support in Mbezi Beach',
      category: 'Logistics',
      pay: 'TZS 60,000',
      distance: '6.5 km',
      time: 'Tomorrow',
      rating: '4.7',
      verified: true,
      latitude: -6.7000,
      longitude: 39.2300,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.role == UserRole.worker;
    final visibleJobs = _category == 'All'
        ? _jobs
        : _jobs.where((job) => job.category == _category).toList();

    if (!isWorker) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
        HeroPanel(
          isWorker: false,
          loggedIn: widget.loggedIn,
          onPrimaryAction: widget.loggedIn
              ? widget.onPostTask
              : widget.onEmployerCta,
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Hiring desk',
          action: 'Post',
          onAction: widget.onPostTask,
        ),
        const SizedBox(height: 14),
        const EmployerDashboard(),
      ],
    );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : MfColors.ink.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ViewTab(
                    label: 'Map',
                    icon: MfMapTabIcon(
                      selected: _view == _DiscoverView.map,
                      size: 20,
                    ),
                    selected: _view == _DiscoverView.map,
                    onTap: () => setState(() => _view = _DiscoverView.map),
                  ),
                ),
                Expanded(
                  child: _ViewTab(
                    label: 'List',
                    icon: MfListTabIcon(
                      selected: _view == _DiscoverView.list,
                      size: 20,
                    ),
                    selected: _view == _DiscoverView.list,
                    onTap: () => setState(() => _view = _DiscoverView.list),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Domestic', 'Logistics', 'Care', 'Technical']
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        checkmarkColor: Colors.white,
                        onSelected: (_) =>
                            setState(() => _category = category),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        labelStyle: TextStyle(
                          color: _category == category
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : MfColors.ink),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _view == _DiscoverView.map
                ? JobsMapView(
                    jobs: visibleJobs,
                    onJobTap: widget.onJobTap,
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      HeroPanel(
                        isWorker: true,
                        loggedIn: widget.loggedIn,
                        onPrimaryAction: null,
                      ),
                      const SizedBox(height: 14),
                      ...visibleJobs.map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobCard(
                            job: job,
                            onTap: () => widget.onJobTap(job),
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

class _ViewTab extends StatelessWidget {
  const _ViewTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? MfColors.mutedDark : MfColors.muted;
    return Material(
      color: selected ? MfColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected ? Colors.white : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.isWorker,
    required this.loggedIn,
    this.onPrimaryAction,
  });

  final bool isWorker;
  final bool loggedIn;
  final VoidCallback? onPrimaryAction;

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
                label: !loggedIn && isWorker
                    ? 'Browse as guest'
                    : isWorker
                        ? 'Worker mode'
                        : 'Employer mode',
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
                ? 'Browse open mchongo below. Tap a job and sign in when you’re ready to apply.'
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
                  onPressed: onPrimaryAction,
                  icon: Icon(
                    isWorker ? Icons.work_outline : Icons.add_task_outlined,
                  ),
                  label: Text(
                    isWorker
                        ? (loggedIn ? 'Find mchongo' : 'Browse jobs')
                        : 'Post task',
                  ),
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
  const JobCard({super.key, required this.job, this.onTap});

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
              if (job.verified)
                const MfVerifiedTaskIcon(size: 20)
              else
                Icon(
                  Icons.pending_actions_outlined,
                  color: MfColors.muted,
                  size: 20,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MfTimeClockIcon(size: 14),
                  const SizedBox(width: 4),
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
            ],
          ),
        ),
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
  const PostJobPage({super.key, required this.onStartPost});

  final VoidCallback onStartPost;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          'Post a task',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a short-term job and match verified workers nearby in Dar.',
          style: TextStyle(color: MfColors.muted, height: 1.45),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
                'New mchongo',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Category, details, area, timing, and budget — in a few steps.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: MfColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: onStartPost,
                child: const Text('Start posting'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'How it works',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        const _PostTip(
          step: '1',
          title: 'Pick a category',
          body: 'Domestic, logistics, care, or technical.',
        ),
        const _PostTip(
          step: '2',
          title: 'Describe the work',
          body: 'Title, details, Dar area, and when you need it.',
        ),
        const _PostTip(
          step: '3',
          title: 'Set budget & post',
          body: 'Workers apply, you review, then pay in-app.',
        ),
      ],
    );
  }
}

class _PostTip extends StatelessWidget {
  const _PostTip({
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark
                  ? MfColors.surfaceDarkElevated
                  : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: isDark ? MfColors.primarySoft : MfColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  body,
                  style: TextStyle(
                    color: isDark ? MfColors.mutedDark : MfColors.muted,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? MfColors.primarySoft : MfColors.primary;
    final mutedColor = isDark ? MfColors.mutedDark : MfColors.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: ListTile(
          leading: Icon(icon, color: done ? primaryColor : mutedColor),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: mutedColor),
          ),
          trailing: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? primaryColor : mutedColor,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        SectionHeader(
          title: 'Wallet',
          action: 'Manage',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageWalletPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        const MfBalanceCard(
          title: 'M-Pesa wallet',
          balance: 'TZS 128,500',
          incomeLabel: 'Earned',
          incomeValue: 'TZS 95,000',
          spendLabel: 'Fees',
          spendValue: 'TZS 11,500',
        ),
        const SizedBox(height: 12),
        const MfBalanceCard(
          title: 'Bank payout',
          balance: 'TZS 42,000',
          incomeLabel: 'Incoming',
          incomeValue: 'TZS 42,000',
          spendLabel: 'Withdrawn',
          spendValue: 'TZS 0',
          dark: true,
        ),
        const SizedBox(height: 16),
        MfPrimaryButton(
          label: 'Add payout method',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageWalletPage()),
            );
          },
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

class ManageWalletPage extends StatefulWidget {
  const ManageWalletPage({super.key});

  @override
  State<ManageWalletPage> createState() => _ManageWalletPageState();
}

class _ManageWalletPageState extends State<ManageWalletPage> {
  bool _instantPayouts = true;
  bool _freezeWallet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const MfBalanceCard(
            title: 'M-Pesa wallet',
            balance: 'TZS 128,500',
            incomeLabel: 'Earned',
            incomeValue: 'TZS 95,000',
            spendLabel: 'Fees',
            spendValue: 'TZS 11,500',
          ),
          const SizedBox(height: 18),
          MfSettingsRow(
            icon: Icons.payments_outlined,
            title: 'Daily payout limit',
            subtitle: 'TZS 300,000 / day',
            onTap: () {},
          ),
          const Divider(height: 1),
          MfSettingsRow(
            icon: Icons.bolt_outlined,
            title: 'Instant payouts',
            trailing: Switch.adaptive(
              value: _instantPayouts,
              activeTrackColor: MfColors.primary,
              onChanged: (value) => setState(() => _instantPayouts = value),
            ),
          ),
          const Divider(height: 1),
          MfSettingsRow(
            icon: Icons.ac_unit_outlined,
            title: 'Freeze wallet',
            trailing: Switch.adaptive(
              value: _freezeWallet,
              activeTrackColor: MfColors.primary,
              onChanged: (value) => setState(() => _freezeWallet = value),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Remove payout method',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          MfPrimaryButton(
            label: 'Save',
            onPressed: () {
              showMfSuccessDialog(
                context: context,
                title: 'Great, your wallet is ready',
                message:
                    'You can now receive job payments and withdraw to M-Pesa conveniently.',
                onDone: () => Navigator.of(context).pop(),
              );
            },
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? MfColors.primarySoft : MfColors.primary;
    final inkColor = isDark ? Colors.white : MfColors.ink;

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
                  ? primaryColor
                  : inkColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _biometrics = false;

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
          Text(
            'Verified cleaning specialist',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? MfColors.mutedDark : MfColors.muted,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          MfToggleRow(
            title: 'Get Notifications',
            subtitle:
                'Job matches, hiring updates, and payment alerts from MchongoFasta.',
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const Divider(height: 1),
          MfToggleRow(
            title: 'Log in with Face ID',
            subtitle: 'Use biometrics for faster, safer access to your account.',
            value: _biometrics,
            onChanged: (value) => setState(() => _biometrics = value),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
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
              onChanged: (_) => widget.onThemeToggle(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDark ? Colors.white : MfColors.ink),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback? onAction;

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
          onPressed: onAction ?? () {},
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

