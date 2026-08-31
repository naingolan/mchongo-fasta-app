import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';

class WorkerStats {
  const WorkerStats({
    required this.weekStreak,
    required this.jobsCompleted,
    required this.jobsApplied,
    required this.rating,
    required this.activeDays,
    required this.completedJobs,
  });

  final int weekStreak;
  final int jobsCompleted;
  final int jobsApplied;
  final double rating;
  final Set<DateTime> activeDays;
  final List<CompletedJob> completedJobs;
}

class CompletedJob {
  const CompletedJob({
    required this.title,
    required this.area,
    required this.pay,
    required this.date,
    required this.rating,
  });

  final String title;
  final String area;
  final String pay;
  final DateTime date;
  final double rating;
}

WorkerStats demoWorkerStats() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final active = <DateTime>{
    today,
    today.subtract(const Duration(days: 1)),
    today.subtract(const Duration(days: 2)),
    today.subtract(const Duration(days: 3)),
    today.subtract(const Duration(days: 5)),
    today.subtract(const Duration(days: 8)),
    today.subtract(const Duration(days: 9)),
    today.subtract(const Duration(days: 12)),
    today.subtract(const Duration(days: 15)),
    today.subtract(const Duration(days: 18)),
    today.subtract(const Duration(days: 21)),
  };

  return WorkerStats(
    weekStreak: 4,
    jobsCompleted: 128,
    jobsApplied: 146,
    rating: 4.9,
    activeDays: active,
    completedJobs: [
      CompletedJob(
        title: 'House cleaning',
        area: 'Mikocheni',
        pay: 'TZS 35,000',
        date: today.subtract(const Duration(days: 1)),
        rating: 5.0,
      ),
      CompletedJob(
        title: 'Errand run',
        area: 'Kariakoo',
        pay: 'TZS 18,000',
        date: today.subtract(const Duration(days: 2)),
        rating: 4.8,
      ),
      CompletedJob(
        title: 'Office painting',
        area: 'Masaki',
        pay: 'TZS 95,000',
        date: today.subtract(const Duration(days: 5)),
        rating: 4.9,
      ),
      CompletedJob(
        title: 'Care visit',
        area: 'Kinondoni',
        pay: 'TZS 40,000',
        date: today.subtract(const Duration(days: 8)),
        rating: 5.0,
      ),
      CompletedJob(
        title: 'Furniture move',
        area: 'Upanga',
        pay: 'TZS 55,000',
        date: today.subtract(const Duration(days: 12)),
        rating: 4.7,
      ),
    ],
  );
}

/// Bottom-tab profile for logged-in workers.
class WorkerProfileTab extends StatelessWidget {
  const WorkerProfileTab({
    super.key,
    required this.onThemeToggle,
    required this.stats,
  });

  final VoidCallback onThemeToggle;
  final WorkerStats stats;

  void _openActivity(BuildContext context, {int initialTab = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerActivityPage(
          stats: stats,
          initialTab: initialTab,
        ),
      ),
    );
  }

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
                'A',
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
                    'Asha Mwinyi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Text(
                    'Verified cleaning specialist',
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
        GestureDetector(
          onTap: () => _openActivity(context),
          child: _WeekStreakCard(streak: stats.weekStreak),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Completed',
                value: '${stats.jobsCompleted}',
                onTap: () => _openActivity(context, initialTab: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Applied',
                value: '${stats.jobsApplied}',
                onTap: () => _openActivity(context, initialTab: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Rating',
                value: stats.rating.toStringAsFixed(1),
                onTap: () => _openActivity(context, initialTab: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _openActivity(context),
          child: const Text(
            'View streaks & completed jobs',
            style: TextStyle(
              color: MfColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekStreakCard extends StatelessWidget {
  const _WeekStreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final weekdayIndex = now.weekday - 1; // Mon=0

    return Container(
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
            'Weekly streak',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$streak day${streak == 1 ? '' : 's'} active',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = i < streak || i == weekdayIndex && streak > 0;
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 18,
                      color: active ? MfColors.primary : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap to see streaks & jobs',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MfColors.line),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MfColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: MfColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkerActivityPage extends StatefulWidget {
  const WorkerActivityPage({
    super.key,
    required this.stats,
    this.initialTab = 0,
  });

  final WorkerStats stats;
  final int initialTab;

  @override
  State<WorkerActivityPage> createState() => _WorkerActivityPageState();
}

class _WorkerActivityPageState extends State<WorkerActivityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  bool _isActive(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return widget.stats.activeDays.any(
      (d) => d.year == key.year && d.month == key.month && d.day == key.day,
    );
  }

  List<CompletedJob> get _jobsForSelected {
    if (_selectedDay == null) return widget.stats.completedJobs;
    return widget.stats.completedJobs.where((job) {
      return job.date.year == _selectedDay!.year &&
          job.date.month == _selectedDay!.month &&
          job.date.day == _selectedDay!.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: MfColors.primary,
          unselectedLabelColor: MfColors.muted,
          indicatorColor: MfColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Streaks'),
            Tab(text: 'Completed jobs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MonthStreakTab(
            month: _month,
            selectedDay: _selectedDay,
            isActive: _isActive,
            jobsForDay: _jobsForSelected,
            onPrevMonth: () {
              setState(() {
                _month = DateTime(_month.year, _month.month - 1);
              });
            },
            onNextMonth: () {
              setState(() {
                _month = DateTime(_month.year, _month.month + 1);
              });
            },
            onSelectDay: (day) => setState(() => _selectedDay = day),
          ),
          _CompletedJobsTab(jobs: widget.stats.completedJobs),
        ],
      ),
    );
  }
}

class _MonthStreakTab extends StatelessWidget {
  const _MonthStreakTab({
    required this.month,
    required this.selectedDay,
    required this.isActive,
    required this.jobsForDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime? selectedDay;
  final bool Function(DateTime day) isActive;
  final List<CompletedJob> jobsForDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // Mon=1
    final leading = firstWeekday - 1;
    final monthLabel =
        '${_monthName(month.month)} ${month.year}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: MfColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leading + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();
            final dayNum = index - leading + 1;
            final day = DateTime(month.year, month.month, dayNum);
            final active = isActive(day);
            final selected = selectedDay != null &&
                selectedDay!.year == day.year &&
                selectedDay!.month == day.month &&
                selectedDay!.day == day.day;

            return InkWell(
              onTap: () => onSelectDay(day),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: selected
                      ? MfColors.primary
                      : active
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? MfColors.surfaceDarkElevated
                              : const Color(0xFFEEF2FF))
                          : Theme.of(context).cardColor,
                  border: Border.all(
                    color: selected
                        ? MfColors.primary
                        : active
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? MfColors.primarySoft.withValues(alpha: 0.5)
                                : MfColors.primary.withValues(alpha: 0.35))
                            : (Theme.of(context).brightness == Brightness.dark
                                ? MfColors.lineDark
                                : MfColors.line),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : active
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? MfColors.primarySoft
                                  : MfColors.primary)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : MfColors.ink),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          selectedDay == null
              ? 'Pick a date'
              : 'Activity on ${_monthName(selectedDay!.month)} ${selectedDay!.day}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (jobsForDay.isEmpty)
          const Text(
            'No completed jobs on this day. Active streak days still count.',
            style: TextStyle(color: MfColors.muted),
          )
        else
          ...jobsForDay.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CompletedJobTile(job: job),
            ),
          ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _CompletedJobsTab extends StatelessWidget {
  const _CompletedJobsTab({required this.jobs});

  final List<CompletedJob> jobs;

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'No completed jobs yet.',
          style: TextStyle(color: MfColors.muted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _CompletedJobTile(job: jobs[index]),
    );
  }
}

class _CompletedJobTile extends StatelessWidget {
  const _CompletedJobTile({required this.job});

  final CompletedJob job;

  @override
  Widget build(BuildContext context) {
    final date =
        '${job.date.day}/${job.date.month}/${job.date.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MfColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: MfColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${job.area} • $date',
                  style: const TextStyle(color: MfColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                job.pay,
                style: const TextStyle(
                  color: MfColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '★ ${job.rating.toStringAsFixed(1)}',
                style: const TextStyle(color: MfColors.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Settings extracted from profile (notifications, Face ID, etc.).
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _notifications = true;
  bool _biometrics = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
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
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text(
              'Dark Theme',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Switch.adaptive(
              value: isDark,
              activeTrackColor: MfColors.primary,
              onChanged: (_) => widget.onThemeToggle(),
            ),
          ),
        ],
      ),
    );
  }
}
