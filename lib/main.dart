import 'package:flutter/material.dart';

void main() {
  runApp(const MchongoFastaApp());
}

class MchongoFastaApp extends StatefulWidget {
  const MchongoFastaApp({super.key});

  @override
  State<MchongoFastaApp> createState() => _MchongoFastaAppState();
}

class _MchongoFastaAppState extends State<MchongoFastaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

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
      home: HomeShell(
        isDark: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class AppTheme {
  static const accent = Color(0xFFB8F55D);
  static const ink = Color(0xFF111512);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: const Color(0xFF151A17),
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D100E),
      cardColor: const Color(0xFF171D19),
      dividerColor: Colors.white.withValues(alpha: 0.08),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F8F2),
      cardColor: Colors.white,
      dividerColor: Colors.black.withValues(alpha: 0.08),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Lufga',
      fontFamilyFallback: const [
        'Avenir Next',
        'Inter',
        'SF Pro Display',
        'Roboto',
      ],
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }
}

enum UserRole { worker, employer }

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  final bool isDark;
  final VoidCallback onThemeToggle;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0;
  UserRole _role = UserRole.worker;

  @override
  Widget build(BuildContext context) {
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
            tooltip: widget.isDark ? 'Use light mode' : 'Use dark mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
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
                onSelectionChanged: (value) =>
                    setState(() => _role = value.first),
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.flash_on_rounded,
            color: AppTheme.ink,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MchongoFasta',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text('Daily work, verified fast', style: text.labelSmall),
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
        const SizedBox(height: 16),
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
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (isWorker)
          ...visibleJobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
    final surface = theme.colorScheme.surfaceContainerHigh;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                icon: Icons.shield_outlined,
                label: isWorker ? 'Verification: 78%' : 'Employer trusted',
              ),
              const Spacer(),
              const Icon(Icons.near_me_outlined, color: AppTheme.accent),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isWorker
                ? 'Find verified daily work around Dar.'
                : 'Hire reliable help in minutes.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isWorker
                ? 'Cleaning, delivery, care, repairs and errands with ratings, safe payments and fast matching.'
                : 'Post a task, review vetted workers, track completion, then rate and pay securely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    isWorker ? Icons.work_outline : Icons.add_task_outlined,
                  ),
                  label: Text(isWorker ? 'Accept mchongo' : 'Post task'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  job.verified
                      ? Icons.verified_outlined
                      : Icons.pending_actions_outlined,
                  color: job.verified
                      ? AppTheme.accent
                      : theme.colorScheme.onSurfaceVariant,
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(job.time, style: theme.textTheme.labelLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
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

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accent,
          child: Text(
            name.characters.first,
            style: const TextStyle(color: AppTheme.ink),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('$service • $distance • $completed'),
        trailing: StatusPill(icon: Icons.star_border, label: rating),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: theme.cardColor,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
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
        Row(
          children: const [
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
        const SizedBox(height: 14),
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
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: done ? AppTheme.accent : null),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available balance',
                style: TextStyle(color: AppTheme.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'TZS 128,500',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
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
        foregroundColor: AppTheme.ink,
        side: const BorderSide(color: AppTheme.ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      child: Card(
        child: ListTile(
          title: Text(title),
          trailing: Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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
