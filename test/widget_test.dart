import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinical_research_app/main.dart';
import 'package:clinical_research_app/core/models/research_models.dart';
import 'package:clinical_research_app/core/services/neondb_service.dart';
import 'package:clinical_research_app/core/state/project_state.dart';

void main() {
  setUp(() async {
    await NeonDbService.wipeAllTestData();
  });
  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ClinicalResearchApp(),
      ),
    );

    expect(find.text('ClinResearch'), findsOneWidget);
    expect(find.text('TELEMETRY LIVE'), findsOneWidget);
  });

  testWidgets('Full flow: Splash -> Login -> Home -> Live Study Creation -> Project Workspace', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: ClinicalResearchApp(),
      ),
    );

    // 1. Skip splash to Login
    await tester.tap(find.text('Skip to Login →'));
    await tester.pumpAndSettle();

    expect(find.text('ClinResearch Portal'), findsOneWidget);
    expect(find.text('Researcher'), findsOneWidget);
    expect(find.text('Doctor / Specialist'), findsOneWidget);

    // 2. Test Create Account toggle
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('NEW RESEARCHER / DOCTOR REGISTRATION'), findsOneWidget);

    // Switch back to Sign In
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('INVESTIGATOR / RESIDENT SIGN-IN'), findsOneWidget);

    // 3. Login as Researcher
    await tester.tap(find.text('Enter Researcher Portal'));
    await tester.pumpAndSettle();

    // 4. Verify Home Dashboard with clean Live NeonDB state
    expect(find.text('Welcome, Dr. Sarah Lin, MD'), findsOneWidget);
    expect(find.text('Active Collaborative Studies'), findsOneWidget);
    expect(find.text('No Active Clinical Studies'), findsOneWidget);

    // 5. Initiate Live Research Study (Stage 01)
    await tester.tap(find.text('Start New Study').first);
    await tester.pumpAndSettle();

    // Fill study initiation dialog
    await tester.enterText(find.byType(TextField).at(0), 'Novel SGLT2i Cardiorenal Protocol');
    await tester.enterText(find.byType(TextField).at(1), 'Cardiovascular Medicine');
    await tester.enterText(find.byType(TextField).at(2), 'Observed significant improvements in eGFR stabilization.');
    await tester.tap(find.text('Launch Stage 01: Idea Clarification'));
    await tester.pumpAndSettle();

    // Verify inside 8-stage workspace
    expect(find.text('STAGE 1 OF 8: RESEARCH IDEA'), findsOneWidget);

    // 6. Navigate back to Home
    await tester.tap(find.byTooltip('Back to Home Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Active Collaborative Studies'), findsOneWidget);
    expect(find.text('Novel SGLT2i Cardiorenal Protocol'), findsOneWidget);
  });

  testWidgets('Responsive check on compact mobile display (320px width)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: ClinicalResearchApp(),
      ),
    );

    // Skip splash to Login
    await tester.tap(find.text('Skip to Login →'));
    await tester.pumpAndSettle();

    // Login as Researcher
    final loginButtonFinder = find.text('Enter Researcher Portal');
    await tester.ensureVisible(loginButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    // Verify Home renders without RenderFlex overflow
    expect(find.text('ClinResearch'), findsOneWidget);
    expect(find.text('RESEARCHER PORTAL'), findsWidgets);
    expect(tester.takeException(), isNull);
    expect(find.text('No Active Clinical Studies', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Researcher posts study -> Displays in Doctor Inbox -> Mentorship pairing & Admin Live Audit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            container = ProviderScope.containerOf(context);
            return const ClinicalResearchApp();
          },
        ),
      ),
    );

    // Skip to Login
    await tester.tap(find.text('Skip to Login →'));
    await tester.pumpAndSettle();

    // 1. Login as Researcher
    await tester.tap(find.text('Enter Researcher Portal'));
    await tester.pumpAndSettle();

    // 2. Post a new study as Researcher
    container.read(appStateProvider.notifier).createNewProject(
      title: 'High-Sensitivity Troponin in Acute PE Trajectories',
      clinicalArea: 'Emergency Medicine & Cardiology',
      observationText: 'Observed unexplained troponin elevation in submassive PE patients without CAD.',
    );
    await tester.pumpAndSettle();

    expect(find.text('High-Sensitivity Troponin in Acute PE Trajectories'), findsOneWidget);

    // 3. Switch to Doctor / Specialist Portal
    container.read(appStateProvider.notifier).switchRole(UserRole.specialist);
    await tester.pumpAndSettle();

    // Verify Doctor Portal is now active
    expect(find.text('DOCTOR / SPECIALIST PORTAL'), findsWidgets);
    expect(find.text('NEW RESEARCH PROPOSAL • DOCTOR INBOX'), findsOneWidget);
    expect(find.textContaining('High-Sensitivity Troponin in Acute PE Trajectories'), findsWidgets);

    // 4. Test Notification Icon Action
    final notifIconFinder = find.byTooltip('Clinical Notifications & Alerts');
    expect(notifIconFinder, findsOneWidget);
    await tester.tap(notifIconFinder);
    await tester.pumpAndSettle();

    // Verify Notification modal opens
    expect(find.text('Clinical Notifications'), findsOneWidget);
    expect(find.text('New Research Mentorship Proposal'), findsWidgets);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // 5. Doctor accepts mentorship for the researcher's newly posted study
    await tester.tap(find.text('Accept Mentorship & Co-Author'));
    await tester.pumpAndSettle();

    // Verify Doctor enters workspace paired as Mentor & Stage advances to Stage 4 Joint Discussion
    expect(find.text('STAGE 4 OF 8: JOINT DISCUSSION'), findsOneWidget);
    expect(find.textContaining('Prof. Marcus Vance'), findsWidgets);

    // 6. Verify live audit trail has logged the events
    final auditEvents = container.read(appStateProvider).auditEvents;
    expect(auditEvents.any((a) => a.title.contains('New Study Posted')), isTrue);
    expect(auditEvents.any((a) => a.title.contains('Doctor Co-Author Paired')), isTrue);
  });
}
